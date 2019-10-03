//
//  MPDocument.m
//  MacPass
//
//  Created by Michael Starke on 08.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPDocument.h"
#import "MPAppDelegate.h"
#import "MPDocumentWindowController.h"
#import "MPDatabaseVersion.h"
#import "MPIconHelper.h"
#import "MPActionHelper.h"
#import "MPSettingsHelper.h"
#import "MPNotifications.h"
#import "MPConstants.h"
#import "MPSavePanelAccessoryViewController.h"
#import "MPTreeDelegate.h"
#import "MPTargetNodeResolving.h"
#import "MPErrorRecoveryAttempter.h"
#import "MPPasswordInputController.h"

#import "KeePassKit/KeePassKit.h"

#import "NSError+Messages.h"
#import "NSString+MPPasswordCreation.h"
#import "NSString+MPHash.h"
#import "NSApplication+MPAdditions.h"

NSString *const MPDocumentDidAddGroupNotification             = @"com.hicknhack.macpass.MPDocumentDidAddGroupNotification";
NSString *const MPDocumentDidAddEntryNotification             = @"com.hicknhack.macpass.MPDocumentDidAddEntryNotification";

NSString *const MPDocumentDidRevertNotifiation                = @"com.hicknhack.macpass.MPDocumentDidRevertNotifiation";

NSString *const MPDocumentDidLockDatabaseNotification         = @"com.hicknhack.macpass.MPDocumentDidLockDatabaseNotification";
NSString *const MPDocumentDidUnlockDatabaseNotification       = @"com.hicknhack.macpass.MPDocumentDidUnlockDatabaseNotification";

NSString *const MPDocumentCurrentItemChangedNotification      = @"com.hicknhack.macpass.MPDocumentCurrentItemChangedNotification";

NSString *const MPDocumentWillChangeModelPropertyNotification = @"com.hicknhack.macpass.MPDocumentWillChangeModelPropertyNotification";
NSString *const MPDocumentDidChangeModelPropertyNotification  = @"com.hicknhack.macpass.MPDocumentDidChangeModelPropertyNotification";

NSString *const MPDocumentEntryKey                            = @"MPDocumentEntryKey";
NSString *const MPDocumentGroupKey                            = @"MPDocumentGroupKey";

@interface MPDocument () {
@private
  BOOL _didLockFile;
  BOOL _shoudlSaveOnLock;
}

@property (nonatomic, assign) NSUInteger unlockCount;

@property (strong, nonatomic) MPSavePanelAccessoryViewController *savePanelViewController;

@property (strong, nonatomic) KPKTree *tree;
@property (weak, nonatomic) KPKGroup *root;
@property (nonatomic, strong) KPKCompositeKey *compositeKey;
@property (nonatomic, strong) NSData *encryptedData;
@property (nonatomic, strong) MPTreeDelegate *treeDelegate;

@property (nonatomic, copy) NSArray<KPKNode *> *selectedNodes;

@property (assign) BOOL readOnly;
@property (strong) NSURL *lockFileURL;

@property (strong) IBOutlet NSView *warningView;
@property (weak) IBOutlet NSImageView *warningViewImage;

@property (atomic, assign) BOOL lockedForFileChange;

@end

@implementation MPDocument

+ (NSSet *)keyPathsForValuesAffectingRoot {
  return [NSSet setWithObject:NSStringFromSelector(@selector(tree))];
}

+ (KPKDatabaseFormat)formatForFileType:(NSString *)fileType {
  if( NSOrderedSame == [fileType compare:MPKdbDocumentUTI options:NSCaseInsensitiveSearch]) {
    return KPKDatabaseFormatKdb;
  }
  if( NSOrderedSame == [fileType compare:MPKdbxDocumentUTI options:NSCaseInsensitiveSearch]) {
    return KPKDatabaseFormatKdbx;
  }
  return KPKDatabaseFormatUnknown;
}

+ (NSString *)fileTypeForVersion:(KPKDatabaseFormat)format {
  switch(format) {
    case KPKDatabaseFormatKdb:
      return MPKdbDocumentUTI;
      
    case KPKDatabaseFormatKdbx:
      return MPKdbxDocumentUTI;
      
    default:
      return @"Unknown";
  }
}

+ (BOOL)autosavesInPlace {
  return [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyEnableAutosave];
}

- (instancetype)init {
  self = [super init];
  if(self) {
    _didLockFile = NO;
    _readOnly = NO;
    _lockedForFileChange = NO;
    self.shouldSaveOnLock = NO;
  }
  return self;
}

- (void)dealloc {
  [self _cleanupLock];
}

- (instancetype)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
  self = [self init];
  if(self) {
    self.tree = [[KPKTree alloc] initWithTemplateContents];
  }
  return self;
}

- (void)makeWindowControllers {
  MPDocumentWindowController *windowController = [[MPDocumentWindowController alloc] init];
  [self addWindowController:windowController];
}

- (BOOL)checkAutosavingSafetyAndReturnError:(NSError **)outError {
  if(![super checkAutosavingSafetyAndReturnError:outError]) {
    return NO; // default checking has found an error!
  }
  /* FIXME potential overriding of differnt file format! */
  if(self.encryptedData) {
    return YES;
  }
  if(self.compositeKey.hasPasswordOrKeyFile) {
    return YES; // key is set, so autosave should be save
  }
  
  MPErrorRecoveryAttempter *recovery = [[MPErrorRecoveryAttempter alloc] init];
  recovery.document = self;
  
  NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"WARNING_ON_SAVE_NO_PASSWORD_OR_KEY_SET", ""),
                              NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"WARNING_ON_SAVE_NO_PASSWORD_OR_KEY_SET_SUGGESTION", ""),
                              NSLocalizedRecoveryOptionsErrorKey : @[ NSLocalizedString(@"CHANGE_PASSWORD_WITH_DOTS", ""), NSLocalizedString(@"CANCEL", "") ],
                              NSRecoveryAttempterErrorKey : recovery
                              };
  if(outError != NULL) {
    *outError = [NSError errorWithDomain:MPDefaultErrorDomain code:MPErrorNoPasswordOrKeyFile userInfo:userInfo];
  }
  return NO;
}

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation {
  NSString *proposedExtension = [super fileNameExtensionForType:typeName saveOperation:saveOperation];
  if(!self.fileURL) {
    return proposedExtension;
  }
  NSString *actualExtension = self.fileURL.pathExtension;
  return actualExtension;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
  if(self.encrypted) {
    NSLog(@"%@ should not be called on locked databases!", NSStringFromSelector(_cmd));
    return self.encryptedData;
  }
  if(!self.compositeKey.hasPasswordOrKeyFile) {
    if(outError != NULL) {
      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"WARNING_ON_SAVE_NO_PASSWORD_OR_KEY_SET", "") };
      *outError = [NSError errorWithDomain:MPDefaultErrorDomain code:0 userInfo:userInfo];
    }
    return nil; // Saving without a password/key is not possible
  }
  NSString *fileType = self.fileTypeFromLastRunSavePanel;
  KPKDatabaseFormat format = [self.class formatForFileType:fileType];
  if(format == KPKDatabaseFormatUnknown) {
    if(outError != NULL) {
      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"UNKNOWN_FILE_VERSION", "") };
      *outError = [NSError errorWithDomain:MPDefaultErrorDomain code:0 userInfo:userInfo];
    }
    return nil; // We do not know what version to save!
  }
  return [self.tree encryptWithKey:self.compositeKey format:format error:outError];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  /*
   Delete our old Tree, and just grab the data
   */
  self.tree = nil;
  self.encryptedData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:outError];
  return YES;
}

- (BOOL)revertToContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
  if([super revertToContentsOfURL:absoluteURL ofType:typeName error:outError]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidRevertNotifiation object:self];
    return YES;
  }
  return NO;
}

- (BOOL)isEntireFileLoaded {
  return YES;
}

- (void)close {
  [self _cleanupLock];
  /*
   We store the last url. Restored windows are automatically handled.
   If closeAllDocuments is set, all docs get this message
   */
  if(self.fileURL.isFileURL) {
    [[NSUserDefaults standardUserDefaults] setObject:self.fileURL.absoluteString forKey:kMPSettingsKeyLastDatabasePath];
  }
  self.tree = nil;
  [super close];
}

- (BOOL)shouldRunSavePanelWithAccessoryView {
  return NO;
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel {
  if(!self.savePanelViewController) {
    self.savePanelViewController = [[MPSavePanelAccessoryViewController alloc] init];
  }
  self.savePanelViewController.savePanel = savePanel;
  self.savePanelViewController.document = self;
  
  savePanel.accessoryView = self.savePanelViewController.view;
  [self.savePanelViewController updateView];
  
  return YES;
}

- (NSString *)fileTypeFromLastRunSavePanel {
  if(self.savePanelViewController) {
    return [self.class fileTypeForVersion:self.savePanelViewController.selectedVersion];
  }
  return self.fileType;
}

- (void)presentedItemDidChange {
  NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
  
  [coordinator coordinateReadingItemAtURL:self.fileURL options:NSFileCoordinatorReadingWithoutChanges error:nil byAccessor:^(NSURL * _Nonnull newURL) {
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:newURL.path error:nil];
    if(NSOrderedSame == [attributes.fileModificationDate compare:self.fileModificationDate]) {
      return; // no content change
    }
    
    if(self.encrypted) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self _handleFileChangeWithStrategy:MPFileChangeStrategyUseOther setAsDefault:NO];
      });
      return; // Done!
    }
    
    if(self.lockedForFileChange) {
      return; // We are already displaying an alert
    }
    
    /* Set the flag in this call! */
    self.lockedForFileChange = YES;
    
    /* Dispatch the alert to the main queue */
    dispatch_async(dispatch_get_main_queue(), ^{
      MPFileChangeStrategy strategy = (MPFileChangeStrategy)[NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyFileChangeStrategy];
      if(strategy != MPFileChangeStrategyAsk) {
        [self _handleFileChangeWithStrategy:strategy setAsDefault:NO];
        self.lockedForFileChange = NO;
        return;
      }
      NSAlert *alert = [[NSAlert alloc] init];
      alert.alertStyle = NSWarningAlertStyle;
      alert.messageText = NSLocalizedString(@"FILE_CHANGED_BY_OTHERS_MESSAGE_TEXT", @"Message displayed when an open file was changed from another application");
      alert.informativeText = NSLocalizedString(@"FILE_CHANGED_BY_OTHERS_INFO_TEXT", @"Informative text displayed when the file was change from another application");
      alert.showsSuppressionButton = YES;
      alert.suppressionButton.title = NSLocalizedString(@"SET_AS_DEFAULT_FILE_CHANGE_STRATEGY", @"Checkbox in dialog to set the selection as default file change strategy!");
      [alert addButtonWithTitle:NSLocalizedString(@"FILE_CHANGE_STRATEGY_MERGE", @"Button in dialog to merge changes into file!")];
      [alert addButtonWithTitle:NSLocalizedString(@"KEEP_OTHER_DISCARD_MINE", @"Button in dialog to reopen the file!")];
      [alert addButtonWithTitle:NSLocalizedString(@"KEEP_MINE_DISCARD_OTHER", @"Button in dialog to ignore the changes to an open file!")];
      [alert beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSModalResponse returnCode) {
        BOOL useAsDefault = (alert.suppressionButton.state == NSOnState);
        switch(returnCode) {
          case NSAlertFirstButtonReturn: {
            [self _handleFileChangeWithStrategy:MPFileChangeStrategyMerge setAsDefault:useAsDefault];
            break;
          }
          case NSAlertSecondButtonReturn:
            [self _handleFileChangeWithStrategy:MPFileChangeStrategyUseOther setAsDefault:useAsDefault];
            break;
          case NSAlertThirdButtonReturn:
            [self _handleFileChangeWithStrategy:MPFileChangeStrategyKeepMine setAsDefault:useAsDefault];
          default:
            break;
        }
        self.lockedForFileChange = NO;
      }];
    });
  }];
}

- (void)_handleFileChangeWithStrategy:(MPFileChangeStrategy)strategy setAsDefault:(BOOL)setAsDefault {
  NSAssert(NSThread.currentThread.isMainThread, @"Invoke only on main thread!");
  if(setAsDefault) {
    [NSUserDefaults.standardUserDefaults setInteger:strategy forKey:kMPSettingsKeyFileChangeStrategy];
  }
  
  if(strategy == MPFileChangeStrategyMerge) {
    [self mergeWithContentsFromURL:self.fileURL key:self.compositeKey];
  }
  else if(strategy == MPFileChangeStrategyUseOther) {
    /* dispatch? */
    
    [self revertToContentsOfURL:self.fileURL ofType:self.fileType error:nil];
  }
  // else do nothing!
}

- (void)importTree:(KPKTree *)tree {
  self.tree = tree;
  self.compositeKey = nil;
  self.encryptedData = nil;
}

- (void)writeXMLToURL:(NSURL *)url {
  NSData *xmlData = [self.tree xmlData];
  NSError *error;
  if(![xmlData writeToURL:url options:0 error:&error]) {
    // error handling
  }
}

- (void)readXMLfromURL:(NSURL *)url {
  NSError *error;
  KPKTree *tree = [[KPKTree alloc] initWithXmlContentsOfURL:url error:&error];
  [self importTree:tree];
}

- (void)mergeWithContentsFromURL:(NSURL *)url key:(KPKCompositeKey *)key {
  BOOL mergeKDB;
  
  KPKFileVersion version = [KPKFormat.sharedFormat fileVersionForData:[NSData dataWithContentsOfURL:url]];
  mergeKDB = (version.format == KPKDatabaseFormatKdb);
  
  if(mergeKDB) {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSWarningAlertStyle;
    alert.messageText = NSLocalizedString(@"ALERT_MERGE_KDB_FILE_MESSAGE", @"Alert message warning user about KDB file merge");
    alert.informativeText = NSLocalizedString(@"ALERT_MERGE_KDB_FILE_INFO_TEXT", @"Informative text displayed when merging KDB files");
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_MERGE_CONTINUE", @"Button in dialog to merge KDB changes into file!")];
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_MERGE_CANCEL", @"Button in dialog to cancel merge of KDB file changes!")];
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSModalResponse returnCode) {
      switch(returnCode) {
        case NSAlertFirstButtonReturn:
          [self _mergeWithContentsFromURL:url key:key options:KPKSynchronizationOptionMatchGroupsByTitleOnly];
          break;
        case NSAlertSecondButtonReturn:
        default:
          break;
      }
    }];
  }
  else {
    [self _mergeWithContentsFromURL:url key:key options:0];
  }
}
- (void)_mergeWithContentsFromURL:(NSURL *)url key:(KPKCompositeKey *)key options:(KPKSynchronizationOptions)options {
  NSError *error;
  KPKTree *otherTree;
  
  
  if(key) {
    otherTree = [[KPKTree alloc] initWithContentsOfUrl:url key:key error:&error];
  }
  
  if(otherTree) {
    [self.tree synchronizeWithTree:otherTree mode:KPKSynchronizationModeSynchronize options:options];
    /* the key might have changed so update ours! */
    [self updateChangeCount:NSChangeDone];
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSApp.applicationName;
    notification.informativeText = NSLocalizedString(@"AUTO_MERGE_NOTIFICATION_TEXT", @"Sucessfully merged external changes");
    notification.deliveryDate = NSDate.date;
    [NSUserNotificationCenter.defaultUserNotificationCenter scheduleNotification:notification];
  }
  else {
    if(!key || error.code == KPKErrorPasswordAndOrKeyfileWrong) {
      NSWindow *sheet = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                                    styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
      MPPasswordInputController *passwordInputController = [[MPPasswordInputController alloc] init];
      [passwordInputController requestPasswordWithMessage:NSLocalizedString(@"EXTERN_CHANGE_OF_MASTERKEY", @"The master key was changed by an external program!")
                                              cancelLabel:NSLocalizedString(@"ABORT_MERGE_KEEP_MINE", @"Button label to abort a merge on a file with changed master key!")
                                        completionHandler:^BOOL(NSString *password, NSURL *keyURL, BOOL didCancel, NSError *__autoreleasing *error) {
                                          [self.windowForSheet endSheet:sheet returnCode:(didCancel ? NSModalResponseCancel : NSModalResponseOK)];
                                          if(!didCancel) {
                                            NSData *keyFileData = keyURL ? [NSData dataWithContentsOfURL:keyURL] : nil;
                                            KPKCompositeKey *compositeKey = [[KPKCompositeKey alloc] initWithPassword:password keyFileData:keyFileData];
                                            [self _mergeWithContentsFromURL:url key:compositeKey options:options];
                                          }
                                          // just return yes regardless since we will display the sheet again if needed!
                                          return YES;
                                        }];
      sheet.contentViewController = passwordInputController;
      [self.windowForSheet beginSheet:sheet completionHandler:^(NSModalResponse returnCode) { /* nothing to do, rest is done in other handler! */ }];
    }
    else {
      /* unable to merge */
      NSAlert *alert = [NSAlert alertWithError:error];
      [alert beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSModalResponse returnCode) {
        // do nothing;
      }];
    }
  }
}

#pragma mark Lock/Unlock/Decrypt
- (void)lockDatabase:(id)sender {
  /*
   [self saveDocument] is enqued so that dataOfType is called too late to actually save the database.
   hence we need to get the ok from the NSDocument about the save, otherwise the lock fails!
   */
  // only lock if we do not have user interaction that cannot be dismissed!
  if(!self.lockedForFileChange) {
    for(NSWindow *sheet in self.windowForSheet.sheets) {
      [self.windowForSheet endSheet:sheet];
    }
    if(self.documentEdited || self.shouldSaveOnLock) {
      [self saveDocumentWithDelegate:self didSaveSelector:@selector(_lockDatabaseForDocument:didSave:contextInfo:) contextInfo:NULL];
      self.shouldSaveOnLock = NO;
    }
    else {
      [self _lockDatabaseForDocument:self didSave:YES contextInfo:NULL];
    }
  }
}

- (void)_lockDatabaseForDocument:(NSDocument *)document didSave:(BOOL)didSave contextInfo:(void  *)contextInfo {
  NSAssert(self == document, @"Receiver does not match the actual document!");
  if(self != document) {
    return; // wrong parameters
  }
  if(!didSave) {
    return; // not saved we need to be sure it happend!
  }
  /* FIXME: User feedback is ignored */
  [self exitSearch:self];
  [self.undoManager removeAllActions];
  NSError *error;
  /* use data from disk since we wrote it*/
  self.encryptedData = [NSData dataWithContentsOfURL:self.fileURL options:NSDataReadingUncached error:&error];
  if(nil == self.encryptedData && error ) {
    [self presentError:error];
    return;
  }
  self.tree = nil;
  self.compositeKey = nil;
  self.selectedGroups = nil;
  self.selectedEntries = nil;
  [NSNotificationCenter.defaultCenter postNotificationName:MPDocumentDidLockDatabaseNotification object:self];
}


- (BOOL)unlockWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL error:(NSError *__autoreleasing*)error{
  // TODO: Make this API asynchronous
  NSData *keyFileData = keyFileURL ? [NSData dataWithContentsOfURL:keyFileURL] : nil;
  self.compositeKey = [[KPKCompositeKey alloc] initWithPassword:password keyFileData:keyFileData];
  self.tree = [[KPKTree alloc] initWithData:self.encryptedData key:self.compositeKey error:error];
  
  BOOL isUnlocked = (nil != self.tree);
  
  if(isUnlocked) {
    /* only clear the data if we actually do not need it anymore */
    self.encryptedData = nil;
    self.unlockCount += 1;
    [NSNotificationCenter.defaultCenter postNotificationName:MPDocumentDidUnlockDatabaseNotification object:self];
    [self _storeKeyURL:keyFileURL];
  }
  else {
    self.compositeKey = nil; // clear the key?
  }
  return isUnlocked;
}

- (BOOL)changePassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL {
  /* sanity check? */
  if([password length] == 0 && keyFileURL == nil) {
    return NO;
  }
  NSData *keyFileData = keyFileURL ? [NSData dataWithContentsOfURL:keyFileURL] : nil;
  if(!self.compositeKey) {
    self.compositeKey = [[KPKCompositeKey alloc] initWithPassword:password keyFileData:keyFileData];
  }
  else {
    [self.compositeKey setPassword:password andKeyFileData:keyFileData];
  }
  self.tree.metaData.masterKeyChanged = [NSDate date];
  /* Key change is not undoable so just recored the change as done */
  [self updateChangeCount:NSChangeDone];
  /*
   If the user opted to remember key files for documents, we should update this information.
   But it's impossible to know, if he actually saves the changes!
   */
  return YES;
}

- (NSURL *)suggestedKeyURL {
  MPAppDelegate *delegate = (MPAppDelegate *)NSApp.delegate;
  if(!delegate.isAllowedToStoreKeyFile) {
    return nil;
  }
  NSDictionary *keysForFiles = [NSUserDefaults.standardUserDefaults dictionaryForKey:kMPSettingsKeyRememeberdKeysForDatabases];
  NSString *keyPath = keysForFiles[self.fileURL.path.sha1HexDigest];
  if(!keyPath) {
    return nil;
  }
  return [NSURL fileURLWithPath:keyPath];
}

#pragma mark Properties
- (KPKDatabaseFormat)formatForFileType {
  return [self.class formatForFileType:self.fileType];
}

- (BOOL)encrypted {
  /* we have an encrypted document if there's data loaded but no tree set */
  return (nil != self.encryptedData && self.tree == nil);
}

- (KPKGroup *)root {
  return self.tree.root;
}

- (KPKGroup *)trash {
  return self.tree.trash;
}

- (KPKGroup *)templates {
  /* Caching is dangerous as we might have deleted the group */
  return [self findGroup:self.tree.metaData.entryTemplatesGroupUuid];
}

- (BOOL)hasSearch {
  return self.searchContext != nil;
}

- (void)setTemplates:(KPKGroup *)templates {
  self.tree.templates = templates;
}

- (void)setTrash:(KPKGroup *)trash {
  self.tree.trash = trash;
}

- (void)setTree:(KPKTree *)tree {
  if(self.tree != tree) {
    /* reseting the tree make undo a bit useless */
    [self.undoManager removeAllActions];
    _tree = tree;
    if(nil == self.treeDelegate) {
      self.treeDelegate = [[MPTreeDelegate alloc] initWithDocument:self];
    }
    self.tree.delegate = self.treeDelegate;
  }
}

#pragma mark -
- (void)setSelectedNodes:(NSArray<KPKNode *> *)selectedNodes {
  if(![_selectedNodes isEqualToArray:selectedNodes]) {
    _selectedNodes = [selectedNodes copy];
    [NSNotificationCenter.defaultCenter postNotificationName:MPDocumentCurrentItemChangedNotification object:self];
  }
}

- (void)setSelectedGroups:(NSArray<KPKGroup *> *)selectedGroups {
  if(![self.selectedGroups isEqualToArray:selectedGroups]) {
    _selectedGroups = [selectedGroups copy];
  }
  self.selectedNodes = self.selectedGroups;
}

- (void)setSelectedEntries:(NSArray<KPKEntry *> *)selectedEntries {
  if(![self.selectedEntries isEqualToArray:selectedEntries]) {
    _selectedEntries = [selectedEntries copy];
  }
  self.selectedNodes = self.selectedEntries;
}

#pragma mark Data Accesors

- (KPKEntry *)findEntry:(NSUUID *)uuid {
  return [self.root entryForUUID:uuid];
}

- (KPKGroup *)findGroup:(NSUUID *)uuid {
  return [self.root groupForUUID:uuid];
}

- (NSArray *)allEntries {
  return self.tree.allEntries;
}

- (NSArray *)allGroups {
  return self.tree.allGroups;
}

- (BOOL)shouldEnforcePasswordChange {
  KPKMetaData *metaData = self.tree.metaData;
  if(metaData.enforceMasterKeyChangeOnce) {
    return YES;
  }
  if(!metaData.enforceMasterKeyChange) {
    return NO;
  }
  return ((24*60*60*metaData.masterKeyChangeEnforcementInterval) < - metaData.masterKeyChanged.timeIntervalSinceNow);
}

- (BOOL)shouldRecommendPasswordChange {
  KPKMetaData *metaData = self.tree.metaData;
  if(!metaData.recommendMasterKeyChange) {
    return NO;
  }
  return ( (24*60*60*metaData.masterKeyChangeRecommendationInterval) < - metaData.masterKeyChanged.timeIntervalSinceNow);
}

#pragma mark Data manipulation
- (KPKEntry *)createEntry:(KPKGroup *)parent {
  if(!parent) {
    return nil; // No parent
  }
  if(parent.isTrash || parent.isTrashed) {
    return nil; // no new Groups in trash
  }
  
  if([self.fileType isEqualToString:MPKdbDocumentUTI]) {
    if([self.tree minimumVersionForAddingEntryToGroup:parent].format == KPKDatabaseFormatKdbx) {
      NSLog(@"Warning: Database format does not allow for adding entries to this group!");
    }
  }
  
  KPKEntry *newEntry = [self.tree createEntry:parent];
  /* setting properties on entries is undoable, but we do not want to record this so disable on creation */
  BOOL wasUndoEnabeld = self.undoManager.isUndoRegistrationEnabled;
  [self.undoManager disableUndoRegistration];
  newEntry.title = NSLocalizedString(@"DEFAULT_ENTRY_TITLE", @"Title for a newly created entry");
  if([self.tree.metaData.defaultUserName length] > 0) {
    newEntry.username = self.tree.metaData.defaultUserName;
  }
  NSString *defaultPassword = [NSString passwordWithDefaultSettings];
  if(defaultPassword) {
    newEntry.password = defaultPassword;
  }
  /* re-enable undo/redo if we did turn it off */
  if(wasUndoEnabeld) {
    [self.undoManager enableUndoRegistration];
  }
  [newEntry addToGroup:parent];
  [newEntry.undoManager setActionName:NSLocalizedString(@"NEW_ENTRY", "Action name for a newly created entry")];
  [NSNotificationCenter.defaultCenter postNotificationName:MPDocumentDidAddEntryNotification
                                                    object:self
                                                  userInfo:@{ MPDocumentEntryKey: newEntry }];
  return newEntry;
}

- (KPKGroup *)createGroup:(KPKGroup *)parent {
  if(!parent) {
    return nil; // no parent!
  }
  if(parent.isTrash || parent.isTrashed) {
    return nil; // no new Groups in trash
  }
  KPKGroup *newGroup = [self.tree createGroup:parent];
  /* setting properties on entries is undoable, but we do not want to record this so disable on creation */
  BOOL wasUndoEnabeld = self.undoManager.isUndoRegistrationEnabled;
  [self.undoManager disableUndoRegistration];
  newGroup.title = NSLocalizedString(@"DEFAULT_GROUP_NAME", @"Title for a newly created group");
  newGroup.iconId = MPIconFolder;
  /* re-enable undo/redo if we did turn it off */
  if(wasUndoEnabeld) {
    [self.undoManager enableUndoRegistration];
  }
  [newGroup addToGroup:parent];
  [newGroup.undoManager setActionName:NSLocalizedString(@"NEW_GROUP", "Action name for a newly created group")];
  [NSNotificationCenter.defaultCenter postNotificationName:MPDocumentDidAddGroupNotification
                                                    object:self
                                                  userInfo:@{ MPDocumentGroupKey : newGroup }];
  return newGroup;
}

- (KPKAttribute *)createCustomAttribute:(KPKEntry *)entry {
  NSString *title = NSLocalizedString(@"DEFAULT_CUSTOM_FIELD_TITLE", @"Default Titel for new Custom-Fields");
  NSString *value = NSLocalizedString(@"DEFAULT_CUSTOM_FIELD_VALUE", @"Default Value for new Custom-Fields");
  KPKAttribute *newAttribute = [[KPKAttribute alloc] initWithKey:title value:value];
  [entry addCustomAttribute:newAttribute];
  return newAttribute;
}

- (void)deleteNode:(KPKNode *)node {
  if(!node.asEntry && !node.asGroup) {
    return; // Nothing do
  }
  if(node.isTrashed) {
    [self _presentTrashAlertForItem:node];
    return;
  }
  
  if(node.asEntry.isHistory) {
    [self.historyEntry removeHistoryEntry:node.asEntry];
    return;
  }
  
  if(!self.tree.metaData.useTrash) {
    /* Display warning about permanently removing items! */
  }
  [node trashOrRemove];
  BOOL permanent = !node.isTrashed;
  if(node.asGroup) {
    [self.undoManager setActionName:permanent ? NSLocalizedString(@"DELETE_GROUP", "Delete Group") : NSLocalizedString(@"TRASH_GROUP", "Move Group to Trash")];
  }
  else if(node.asEntry) {
    [self.undoManager setActionName:permanent ? NSLocalizedString(@"DELETE_ENTRY", "Delete Entry") : NSLocalizedString(@"TRASH_ENTRY", "Move Entry to Trash")];
  }
}

#pragma mark Actions
- (void)emptyTrash:(id)sender {
  NSAlert *alert = [[NSAlert alloc] init];
  alert.alertStyle = NSWarningAlertStyle;
  alert.messageText = NSLocalizedString(@"WARNING_ON_EMPTY_TRASH_TITLE", "Message text for the alert displayed when clearing the Trash");
  alert.informativeText = NSLocalizedString(@"WARNING_ON_EMPTY_TRASH_DESCRIPTION", "Informative Text displayed when clearing the Trash");
  
  [alert addButtonWithTitle:NSLocalizedString(@"EMPTY_TRASH", "Empty Trash")];
  [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "Cancel")];
  alert.buttons.lastObject.keyEquivalent = [NSString stringWithFormat:@"%c", 0x1b];
  
  [alert beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSModalResponse returnCode) {
    if(returnCode == NSAlertFirstButtonReturn) {
      [self _emptyTrash];
    }
  }];
}

- (void)_presentTrashAlertForItem:(KPKNode *)node {
  KPKEntry *entry = node.asEntry;
  
  NSAlert *alert = [[NSAlert alloc] init];
  alert.alertStyle = NSWarningAlertStyle;
  alert.messageText = NSLocalizedString(@"WARNING_ON_DELETE_TRASHED_NODE_TITLE", "Message text for the alert displayed when deleting a node");
  alert.informativeText = NSLocalizedString(@"WARNING_ON_DELETE_TRASHED_NODE_DESCRIPTION", "Informative Text displayed when clearing the Trash");
  
  NSString *okButtonText = entry ? NSLocalizedString(@"DELETE_TRASHED_ENTRY", "Empty Trash") : NSLocalizedString(@"DELETE_TRASHED_GROUP", "Empty Trash");
  [alert addButtonWithTitle:okButtonText];
  [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "Cancel")];
  alert.buttons.lastObject.keyEquivalent = [NSString stringWithFormat:@"%c", 0x1b];
  
  [alert beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSModalResponse returnCode) {
    if(returnCode == NSAlertFirstButtonReturn) {
      /* No undo on this operation */
      for( KPKEntry *entry in node.asGroup.childEntries) {
        [node.undoManager removeAllActionsWithTarget:entry];
      }
      for(KPKGroup *group in node.asGroup.childGroups) {
        [node.undoManager removeAllActionsWithTarget:group];
      }
      //[self.undoManager setActionIsDiscardable:YES];
      [node remove];
    }
  }];
}

- (void)createEntryFromTemplate:(id)sender {
  if(![sender respondsToSelector:@selector(representedObject)]) {
    return; // sender cannot provide useful data
  }
  id obj = [sender representedObject];
  if(![obj isKindOfClass:NSUUID.class]) {
    return; // sender cannot provide NSUUID
  }
  NSUUID *entryUUID = [sender representedObject];
  if(entryUUID) {
    KPKEntry *templateEntry = [self findEntry:entryUUID];
    KPKGroup *group = self.selectedGroups.count == 1 ? self.selectedGroups.firstObject : nil;
    if(templateEntry && group) {
      KPKEntry *copy = [templateEntry copyWithTitle:templateEntry.title options:kKPKCopyOptionNone];
      
      BOOL updatePassword = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyUpdatePasswordOnTemplateEntries];
      if( updatePassword ) {
        BOOL undoEnabled = self.undoManager.isUndoRegistrationEnabled;
        [self.undoManager disableUndoRegistration];
        NSString *password = [NSString passwordWithDefaultSettings];
        if( password ) {
          copy.password = password;
        }
        if(undoEnabled) {
          [self.undoManager enableUndoRegistration];
        }
      }
      [copy addToGroup:group];
      [self.undoManager setActionName:NSLocalizedString(@"ADD_TREMPLATE_ENTRY", "Action to add an entry via template")];
    }
  }
}

- (void)duplicateEntry:(id)sender {
  [self duplicateEntryWithOptions:kKPKCopyOptionNone];
}

- (void)duplicateEntryWithOptions:(KPKCopyOptions)options { 
  for(KPKEntry *entry in self.selectedEntries) {
    KPKEntry *duplicate = [entry copyWithTitle:nil options:options];
    [duplicate addToGroup:entry.parent];
  }
  [self.undoManager setActionName:[NSString stringWithFormat:NSLocalizedString(@"DUPLICATE_ENTRIES_ACTION_NAME", @"Action name for duplicating entries"), self.selectedEntries.count]];
}

- (void)duplicateGroup:(id)sender {
  for(KPKGroup *group in self.selectedGroups) {
    KPKGroup *duplicate = [group copyWithTitle:nil options:kKPKCopyOptionNone];
    /* if group is root group, add the duplicate below */
    [duplicate addToGroup:(group.parent ? group.parent : group)];
  }
  [self.undoManager setActionName:[NSString stringWithFormat:NSLocalizedString(@"DUPLICATE_GROUPS_ACTION_NAME", @"Action name for duplicating groups"), self.selectedGroups.count]];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  return [self validateUserInterfaceItem:menuItem];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
  return [self validateUserInterfaceItem:theItem];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
  id<MPTargetNodeResolving> entryResolver = [NSApp targetForAction:@selector(currentTargetEntries)];
  id<MPTargetNodeResolving> groupResolver = [NSApp targetForAction:@selector(currentTargetGroups)];
  id<MPTargetNodeResolving> nodeResolver = [NSApp targetForAction:@selector(currentTargetNodes)];
  
  
  NSArray *targetNodes = nodeResolver.currentTargetNodes;
  NSArray *targetGroups = groupResolver.currentTargetGroups;
  NSArray *targetEntries = entryResolver.currentTargetEntries;
  
  KPKEntry *targetEntry = targetEntries.count == 1 ? targetEntries.firstObject : nil;
  KPKGroup *targetGroup = targetGroups.count == 1 ? targetGroups.firstObject : nil;
  
  if(self.encrypted || self.isReadOnly) {
    return NO;
  }
  
  BOOL valid = /*targetNode ? targetNode.isEditable : */YES;
  switch([MPActionHelper typeForAction:anItem.action]) {
    case MPActionAddGroup:
      valid &= (nil != targetGroup);
      valid &= !targetGroup.isTrash;
      valid &= !targetGroup.isTrashed;
      valid &= !self.historyEntry;
      break;
    case MPActionAddEntry:
      valid &= (nil != targetGroup);
      valid &= !targetGroup.isTrash;
      valid &= !targetGroup.isTrashed;
      valid &= !self.historyEntry;
      break;
    case MPActionDelete:
      valid &= targetNodes.count > 0;
      for(KPKNode *node in targetNodes) {
        valid &= (self.trash != node);
        valid &= (node != self.tree.root);
        if(!valid) {
          break;
        }
      }
      break;
    case MPActionDuplicateEntry:
    case MPActionDuplicateEntryWithOptions:
      valid &= targetEntries.count > 0;
      valid &= !self.historyEntry;
      break;
    case MPActionDuplicateGroup:
      valid &= targetGroups.count > 0;
      break;
    case MPActionEmptyTrash:
      valid &= (self.trash.groups.count + self.trash.entries.count) > 0;
      break;
    case MPActionDatabaseSettings:
    case MPActionEditPassword:
    case MPActionLock:
      valid &= !self.encrypted;
      break;
    case MPActionShowEntryHistory:
      valid &= (nil != targetEntry);
      valid &= targetEntry.history.count > 0;
      valid &= !self.historyEntry;
      break;
      /* Entry View Actions */
    case MPActionCopyUsername:
      valid &= (nil != targetEntry) && (targetEntry.username.length > 0);
      break;
    case MPActionCopyPassword:
      valid &= (nil != targetEntry ) && (targetEntry.password.length > 0);
      break;
    case MPActionCopyURL:
    case MPActionOpenURL:
      valid &= (nil != targetEntry ) && (targetEntry.url.length > 0);
      break;
    case MPActionPerformAutotypeForSelectedEntry:
    case MPActionCopyCustomAttribute:
    case MPActionCopyAsReference:
      valid &= (nil != targetEntry);
      break;
    case MPActionShowGroupInOutline:
      valid &= (nil != targetEntry);
      valid &= self.hasSearch;
      break;
    default:
      break;
  }
  return (valid && [super validateUserInterfaceItem:anItem]);
}

- (void)_storeKeyURL:(NSURL *)keyURL {
  NSMutableDictionary *keysForFiles = [[NSUserDefaults.standardUserDefaults dictionaryForKey:kMPSettingsKeyRememeberdKeysForDatabases] mutableCopy];
  MPAppDelegate *delegate = (MPAppDelegate *)[NSApp delegate];
  if(!delegate.isAllowedToStoreKeyFile || nil == keyURL) {
    /* user has removed the keyfile or we should not safe it so remove it */
    [keysForFiles removeObjectForKey:self.fileURL.path.sha1HexDigest];
  }
  else if(self.compositeKey.hasPassword && self.compositeKey.hasKeyFile) {
    if(nil == keysForFiles) {
      keysForFiles = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    keysForFiles[self.fileURL.path.sha1HexDigest] = keyURL.path;
  }
  if(keysForFiles) {
    [NSUserDefaults.standardUserDefaults setObject:keysForFiles forKey:kMPSettingsKeyRememeberdKeysForDatabases];
  }
}

- (void)_cleanupLock {
  if(_didLockFile) {
    [NSFileManager.defaultManager removeItemAtURL:_lockFileURL error:nil];
    _didLockFile = NO;
  }
}

- (void)_emptyTrash {
  for(KPKEntry *entry in [self.trash childEntries]) {
    [self.undoManager removeAllActionsWithTarget:entry];
  }
  for(KPKGroup *group in [self.trash childGroups]) {
    [self.undoManager removeAllActionsWithTarget:group];
  }
  [self.trash clear];
  /* Update the change count to mark the document state as changed */
  [self updateChangeCount:NSChangeDone];
}

#pragma mark -
#pragma mark MPTargetNodeResolving

- (NSArray<KPKEntry *> *)currentTargetEntries {
  return self.selectedEntries;
}

- (NSArray<KPKGroup *> *)currentTargetGroups {
  return self.selectedGroups;
}

#pragma mark -
#pragma mark MPModelChangeObserving

- (void)willChangeModelProperty {
  [NSNotificationCenter.defaultCenter postNotificationName:MPDocumentWillChangeModelPropertyNotification object:self];
}

- (void)didChangeModelProperty {
  [NSNotificationCenter.defaultCenter postNotificationName:MPDocumentDidChangeModelPropertyNotification object:self];
}

@end
