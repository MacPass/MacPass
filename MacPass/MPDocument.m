//
//  MPDocument.m
//  MacPass
//
//  Created by Michael Starke on 08.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPDatabaseVersion.h"
#import "MPIconHelper.h"
#import "MPActionHelper.h"
#import "MPSettingsHelper.h"
#import "MPNotifications.h"
#import "MPConstants.h"
#import "MPSavePanelAccessoryViewController.h"

#import "DDXMLNode.h"

#import "KPKEntry.h"
#import "KPKGroup.h"
#import "KPKTree.h"
#import "KPKTree+Serializing.h"
#import "KPKPassword.h"
#import "KPKMetaData.h"
#import "KPKAttribute.h"

NSString *const MPDocumentDidAddGroupNotification         = @"com.hicknhack.macpass.MPDocumentDidAddGroupNotification";
NSString *const MPDocumentDidRevertNotifiation            = @"com.hicknhack.macpass.MPDocumentDidRevertNotifiation";

NSString *const MPDocumentEntryKey                        = @"MPDocumentEntryKey";
NSString *const MPDocumentGroupKey                        = @"MPDocumentGroupKey";

typedef NS_ENUM(NSUInteger, MPAlertType) {
  MPAlertTypeEmptryTrash,
  MPAlertTypeDeleteTrashed
};

@interface MPDocument () {
@private
  BOOL _didLockFile;
  NSData *_encryptedData;
}

@property (strong, nonatomic) MPSavePanelAccessoryViewController *savePanelViewController;

@property (strong, nonatomic) KPKTree *tree;
@property (weak, nonatomic) KPKGroup *root;

@property (assign, nonatomic) BOOL hasPasswordOrKey;
@property (assign) BOOL readOnly;

@property (strong) NSURL *lockFileURL;

@property (readonly) BOOL useTrash;
@property (strong) IBOutlet NSView *warningView;
@property (weak) IBOutlet NSImageView *warningViewImage;

@end


@implementation MPDocument

+ (KPKVersion)versionForFileType:(NSString *)fileType {
  if( NSOrderedSame == [fileType compare:MPLegacyDocumentUTI options:NSCaseInsensitiveSearch]) {
    return KPKLegacyVersion;
  }
  if( NSOrderedSame == [fileType compare:MPXMLDocumentUTI options:NSCaseInsensitiveSearch]) {
    return KPKXmlVersion;
  }
  return KPKUnknownVersion;
}

+ (NSString *)fileTypeForVersion:(KPKVersion)version {
  switch(version) {
    case KPKLegacyVersion:
      return MPLegacyDocumentUTI;
    
    case KPKXmlVersion:
      return MPXMLDocumentUTI;

    default:
      return @"Unknown";
  }
}

+ (BOOL)autosavesInPlace {
  return NO;
}

- (id)init {
  self = [super init];
  if(self) {
    _encryptedData = nil;
    _didLockFile = NO;
    _hasPasswordOrKey = NO;
    _readOnly = NO;
    self.tree = [KPKTree templateTree];
  }
  return self;
}

- (void)dealloc {
  [self _cleanupLock];
}

- (void)makeWindowControllers {
  MPDocumentWindowController *windowController = [[MPDocumentWindowController alloc] init];
  [self addWindowController:windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  if(!self.hasPasswordOrKey) {
    return NO; // No password or key. No save possible
  }
  KPKPassword *password = [[KPKPassword alloc] initWithPassword:self.password key:self.key];
  NSString *fileType = [self fileTypeFromLastRunSavePanel];
  KPKVersion version = [[self class] versionForFileType:fileType];
  if(version == KPKUnknownVersion) {
    if(outError != NULL) {
      *outError = [NSError errorWithDomain:MPErrorDomain code:0 userInfo:nil];
    }
    return NO;
  }
  NSData *treeData = [self.tree encryptWithPassword:password forVersion:version error:outError];
  if(![treeData writeToURL:url options:0 error:outError]) {
    NSLog(@"%@", [*outError localizedDescription]);
    return NO;
  }
  return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  /* FIXME: Lockfile handling
   self.lockFileURL = [url URLByAppendingPathExtension:@"lock"];
   if([[NSFileManager defaultManager] fileExistsAtPath:[_lockFileURL path]]) {
   self.readOnly = YES;
   }
   else {
   [[NSFileManager defaultManager] createFileAtPath:[_lockFileURL path] contents:nil attributes:nil];
   _didLockFile = YES;
   self.readOnly = NO;
   }
   */
  /*
   Delete our old Tree, and just grab the data
   */
  self.tree = nil;
  _encryptedData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:outError];
  return YES;
}

- (BOOL)revertToContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
  self.tree = nil;
  if([self readFromURL:absoluteURL ofType:typeName error:outError]) {
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
   We store the last url. Restored windows are automatically handeld.
   If closeAllDocuments is set, all docs get this messgae
   */
  if([[self fileURL] isFileURL]) {
    [[NSUserDefaults standardUserDefaults] setObject:[self.fileURL absoluteString] forKey:kMPSettingsKeyLastDatabasePath];
  }
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
  
  [savePanel setAccessoryView:[self.savePanelViewController view]];
  [self.savePanelViewController updateView];

  return YES;
}

- (NSString *)fileTypeFromLastRunSavePanel {
  if(self.savePanelViewController) {
    return [[self class] fileTypeForVersion:self.savePanelViewController.selectedVersion];
  }
  return [self fileType];
}

- (void)writeXMLToURL:(NSURL *)url {
  NSData *xmlData = [self.tree xmlData];
  [xmlData writeToURL:url atomically:YES];
}

#pragma mark Lock/Unlock/Decrypt

- (BOOL)unlockWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL error:(NSError *__autoreleasing*)error{
  KPKPassword *passwordData = [[KPKPassword alloc] initWithPassword:password key:keyFileURL];
  
  self.key = keyFileURL;
  self.password = [password length] > 0 ? password : nil;
  
  self.tree = [[KPKTree alloc] initWithData:_encryptedData password:passwordData error:error];

  return (self.tree != nil);
}

- (void)lockDatabase:(id)sender {
  KPKPassword *password = [[KPKPassword alloc] initWithPassword:self.password key:self.key];
  NSError *error;
  /* Locking needs to be lossless hence just use the XML format */
  _encryptedData = [self.tree encryptWithPassword:password forVersion:KPKXmlVersion error:&error];
  self.tree = nil;
}

#pragma mark Properties

- (KPKVersion)versionForFileType {
  return [[self class] versionForFileType:[self fileType]];
}

- (BOOL)encrypted {
  return (self.tree == nil);
}

- (KPKGroup *)root {
  return self.tree.root;
}

- (void)setPassword:(NSString *)password {
  if(![_password isEqualToString:password]) {
    _password = [password copy];
    [self _updateIsSecured];
  }
}

- (void)setKey:(NSURL *)key {
  if(![[_key absoluteString] isEqualToString:[key absoluteString]]) {
    _key = key;
    [self _updateIsSecured];
  }
}

- (void)setSelectedGroup:(KPKGroup *)selectedGroup {
  if(_selectedGroup != selectedGroup) {
    _selectedGroup = selectedGroup;
  }
  self.selectedItem = _selectedGroup;
}

- (void)setSelectedEntry:(KPKEntry *)selectedEntry {
  if(_selectedEntry != selectedEntry) {
    _selectedEntry = selectedEntry;
  }
  self.selectedItem = selectedEntry;
}

- (void)setSelectedItem:(id)selectedItem {
  if(_selectedItem != selectedItem) {
    _selectedItem = selectedItem;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPCurrentItemChangedNotification object:self];
  }
}
- (void)setTree:(KPKTree *)tree {
  if(_tree != tree) {
    _tree = tree;
    _tree.undoManager = [self undoManager];
  }
}

#pragma mark Data Accesors

- (KPKEntry *)findEntry:(NSUUID *)uuid {
  return [self.root entryForUUID:uuid];
}

- (KPKGroup *)findGroup:(NSUUID *)uuid {
  return [self.root groupForUUID:uuid];
}

- (BOOL)useTrash {
  return self.tree.metaData.recycleBinEnabled;
}

- (KPKGroup *)trash {
  static KPKGroup *_trash = nil;
  if(self.useTrash) {
    BOOL trashValid = [_trash.uuid isEqual:self.tree.metaData.recycleBinUuid];
    if(!trashValid) {
      _trash = [self findGroup:self.tree.metaData.recycleBinUuid];
    }
    return _trash;
  }
  return nil;
}

- (KPKGroup *)templates {
  static KPKGroup *_templates = nil;
  BOOL templateValid = [_templates.uuid isEqual:self.tree.metaData.entryTemplatesGroup];
  if(!templateValid) {
    _templates = [self findGroup:self.tree.metaData.entryTemplatesGroup];
  }
  return _templates;
}

- (BOOL)isItemTrashed:(id)item {
  BOOL validItem = [item isKindOfClass:[KPKEntry class]] || [item isKindOfClass:[KPKGroup class]];
  if(!item) {
    return NO;
  }
  if(item == self.trash) {
    return NO; // No need to look further as this is the trashcan
  }
  if(validItem) {
    BOOL isTrashed = NO;
    id parent = [item parent];
    while( parent && !isTrashed ) {
      isTrashed = (parent == self.trash);
      parent = [parent parent];
    }
    return isTrashed;
  }
  return NO;
}

- (void)useGroupAsTrash:(KPKGroup *)group {
  if(self.useTrash) {
    if(![self.tree.metaData.recycleBinUuid isEqual:group.uuid]) {
      self.tree.metaData.recycleBinUuid = group.uuid;
    }
  }
}

- (void)useGroupAsTemplate:(KPKGroup *)group {
  if(![self.tree.metaData.entryTemplatesGroup isEqual:group.uuid]) {
    self.tree.metaData.entryTemplatesGroup = group.uuid;
  }
}

#pragma mark Data manipulation
- (KPKEntry *)createEntry:(KPKGroup *)parent {
  if(!parent) {
    return nil; // No parent
  }
  if(parent == self.trash) {
    return nil; // no new Groups in trash
  }
  if([self isItemTrashed:parent]) {
    return nil;
  }
  KPKEntry *newEntry = [self.tree createEntry:parent];
  newEntry.title = NSLocalizedString(@"DEFAULT_ENTRY_TITLE", @"Title for a newly created entry");
  if([self.tree.metaData.defaultUserName length] > 0) {
    newEntry.title = self.tree.metaData.defaultUserName;
  }
  [parent addEntry:newEntry];
  return newEntry;
}

- (KPKGroup *)createGroup:(KPKGroup *)parent {
  if(!parent) {
    return nil; // no parent!
  }
  if(parent == self.trash) {
    return nil; // no new Groups in trash
  }
  if([self isItemTrashed:parent]) {
    return nil;
  }
  KPKGroup *newGroup = [self.tree createGroup:parent];
  newGroup.name = NSLocalizedString(@"DEFAULT_GROUP_NAME", @"Title for a newly created group");
  newGroup.icon = MPIconFolder;
  [parent addGroup:newGroup];
  NSDictionary *userInfo = @{ MPDocumentGroupKey : newGroup };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidAddGroupNotification object:self userInfo:userInfo];
  return newGroup;
}

- (KPKAttribute *)createCustomAttribute:(KPKEntry *)entry {
  NSString *title = NSLocalizedString(@"DEFAULT_CUSTOM_FIELD_TITLE", @"Default Titel for new Custom-Fields");
  NSString *value = NSLocalizedString(@"DEFAULT_CUSTOM_FIELD_VALUE", @"Default Value for new Custom-Fields");
  title = [entry proposedKeyForAttributeKey:title];
  KPKAttribute *newAttribute = [[KPKAttribute alloc] initWithKey:title value:value];
  [entry addCustomAttribute:newAttribute];
  return newAttribute;
}

- (void)deleteEntry:(KPKEntry *)entry {
  if(self.useTrash) {
    if(!self.trash) {
      [self _createTrashGroup];
    }
    if([self isItemTrashed:entry]) {
      return; // Entry is already trashed
    }
    [entry moveToGroup:self.trash atIndex:[self.trash.entries count]];
    [[self undoManager] setActionName:NSLocalizedString(@"TRASH_ENTRY", "Move Entry to Trash")];
  }
  else {
    [entry remove];
    [[self undoManager] setActionName:NSLocalizedString(@"DELETE_ENTRY", "")];
  }
  self.selectedEntry = nil;
}

- (void)deleteGroup:(KPKGroup *)group {
  if(self.useTrash) {
    if(!self.trash) {
      [self _createTrashGroup];
    }
    if( (group == self.trash) || [self isItemTrashed:group] ) {
      return; //Groups already trashed cannot be deleted
    }
    [group moveToGroup:self.trash atIndex:[self.trash.groups count]];
    [[self undoManager] setActionName:NSLocalizedString(@"TRASH_GROUP", "Move Group to Trash")];
  }
  else {
    [group remove];
    [[self undoManager] setActionName:NSLocalizedString(@"DELETE_GROUP", "Delete Group")];
  }
}

#pragma mark Actions

- (void)emptyTrash:(id)sender {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert setMessageText:NSLocalizedString(@"WARNING_ON_EMPTY_TRASH_TITLE", "")];
  [alert setInformativeText:NSLocalizedString(@"WARNING_ON_EMPTY_TRASH_DESCRIPTION", "Informative Text displayed when clearing the Trash")];
  [alert addButtonWithTitle:NSLocalizedString(@"EMPTY_TRASH", "Empty Trash")];
  [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "Cancel")];
  
  [[alert buttons][1] setKeyEquivalent:[NSString stringWithFormat:@"%c", 0x1b]];
  
  NSWindow *window = [[self windowControllers][0] window];
  [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
  if(returnCode == NSAlertFirstButtonReturn) {
    [self _emptyTrash];
  }
}

- (void)createEntryFromTemplate:(id)sender {
  NSMenuItem *item = sender;
  KPKEntry *entry = [item representedObject];
  if(entry) {
    // Create Entry from template;
  }
  return;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
  if([anItem action] == [MPActionHelper actionOfType:MPActionEmptyTrash]) {
    BOOL hasGroups = [self.trash.groups count] > 0;
    BOOL hasEntries = [self.trash.entries count] > 0;
    return (hasEntries || hasGroups);
  }
  
  return [super validateUserInterfaceItem:anItem];
}

#pragma mark Private
- (void)_updateIsSecured {
  BOOL securePassword = ([self.password length] > 0);
  BOOL secureKey = (nil != self.key);
  self.hasPasswordOrKey = (secureKey || securePassword);
}

- (void)_cleanupLock {
  if(_didLockFile) {
    [[NSFileManager defaultManager] removeItemAtURL:_lockFileURL error:nil];
    _didLockFile = NO;
  }
}

- (KPKGroup *)_createTrashGroup {
  /* Maybe push the stuff to the Tree? */
  KPKGroup *trash = [self.tree createGroup:self.tree.root];
  trash.name = NSLocalizedString(@"TRASH", @"Name for the trash group");
  trash.icon = MPIconTrash;
  BOOL registrationEnable = [[self undoManager] isUndoRegistrationEnabled];
  if(registrationEnable) {
    [[self undoManager] disableUndoRegistration];
  }
  [self.tree.root addGroup:trash];
  if(registrationEnable) {
    [[self undoManager] enableUndoRegistration];
  }
  
  self.tree.metaData.recycleBinUuid = trash.uuid;
  return trash;
}

- (void)_emptyTrash {
  for(KPKEntry *entry in [self.trash childEntries]) {
    [[self undoManager] removeAllActionsWithTarget:entry];
  }
  for(KPKGroup *group in [self.trash childGroups]) {
    [[self undoManager] removeAllActionsWithTarget:group];
  }
  [self.trash clear];
}

@end
