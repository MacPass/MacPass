//
//  MPAutotypeDaemon.m
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
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

#import "MPAutotypeDaemon.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPAutotypeCommand.h"
#import "MPAutotypeContext.h"
#import "MPAutotypePaste.h"
#import "MPPasteBoardController.h"
#import "MPSettingsHelper.h"
#import "MPAutotypeCandidateSelectionViewController.h"
#import "MPUserNotificationCenterDelegate.h"

#import "NSApplication+MPAdditions.h"
#import "NSUserNotification+MPAdditions.h"

#import "DDHotKeyCenter.h"
#import "DDHotKey+MacPassAdditions.h"

#import "KeePassKit/KeePassKit.h"
#import <Carbon/Carbon.h>
#import "MPDocumentController.h"

NSString *const kMPWindowTitleKey = @"kMPWindowTitleKey";
NSString *const kMPProcessIdentifierKey = @"kMPProcessIdentifierKey";

@interface MPAutotypeDaemon ()

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) NSData *hotKeyData;
@property (strong) DDHotKey *registredHotKey;
@property (assign) pid_t targetPID; // The pid of the process we want to sent commands to
@property (copy) NSString *targetWindowTitle; // The title of the window that we are targeting
@property (strong) NSRunningApplication *previousApplication; // The application that was active before we got invoked
@property (assign) NSTimeInterval userActionRequested;

@end

@implementation MPAutotypeDaemon

@dynamic autotypeSupported;

#pragma mark -
#pragma mark Lifecylce

static MPAutotypeDaemon *_sharedInstance;

+ (instancetype)defaultDaemon {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[MPAutotypeDaemon alloc] _init];
  });
  return _sharedInstance;
}

- (instancetype)init {
  return nil;
}

- (instancetype)_init {
  NSAssert(_sharedInstance == nil, @"Multiple initializations not allowed on singleton");
  self = [super init];
  if (self) {
    _enabled = NO;
    _targetPID = -1;
    _userActionRequested = NSDate.distantPast.timeIntervalSinceReferenceDate;
    [self bind:NSStringFromSelector(@selector(enabled))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableGlobalAutotype]
       options:nil];
    
    [self bind:NSStringFromSelector(@selector(hotKeyData))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyGlobalAutotypeKeyDataKey]
       options:nil];
    
    [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self
                                                       selector:@selector(_didDeactivateApplication:)
                                                           name:NSWorkspaceDidDeactivateApplicationNotification
                                                         object:nil];
  }
  return self;
}

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self];
  [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self];
  [self unbind:NSStringFromSelector(@selector(enabled))];
  [self unbind:NSStringFromSelector(@selector(hotKeyData))];
}

#pragma mark -
#pragma mark Properties
- (BOOL)autotypeSupported {
  if(@available(macOS 10.14, *)) {
    return AXIsProcessTrusted();
  }
  /* macOS 10.13 and lower allows us to send key events regardless of accessibilty trust */
  return YES;
}

- (void)setEnabled:(BOOL)enabled {
  if(_enabled != enabled) {
    _enabled = enabled;
    self.enabled ? [self _registerHotKey] : [self _unregisterHotKey];
  }
}

- (void)setHotKeyData:(NSData *)hotKeyData {
  if(![_hotKeyData isEqualToData:hotKeyData]) {
    [self _unregisterHotKey];
    _hotKeyData = [hotKeyData copy];
    if(self.enabled) {
      [self _registerHotKey];
    }
  }
}

- (void)checkForAccessibiltyPermissions {
  if(!self.enabled) {
    return;
  }
  BOOL hideAlert = NO;
  if(nil != [NSUserDefaults.standardUserDefaults objectForKey:kMPSettingsKeyAutotypeHideAccessibiltyWarning]) {
    hideAlert = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyAutotypeHideAccessibiltyWarning];
  }
  if(hideAlert || self.autotypeSupported) {
    return;
  }
  else {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSWarningAlertStyle;
    alert.messageText = NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_MESSAGE_TEXT", @"Alert message displayed when Autotype performs self check and lacks accessibilty permissions");
    alert.informativeText = NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_INFORMATIVE_TEXT", @"Alert informative text displayed when Autotype performs self check and lacks accessibilty permissions");
    alert.showsSuppressionButton = YES;
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_BUTTON_OK", @"Button in dialog to leave autotype disabled and continiue!")];
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_BUTTON_OPEN_PREFERENCES", @"Button in dialog to open accessibilty preferences pane!")];
    NSModalResponse returnCode = [alert runModal];
    BOOL suppressWarning = (alert.suppressionButton.state == NSOnState);
    [NSUserDefaults.standardUserDefaults setBool:suppressWarning forKey:kMPSettingsKeyAutotypeHideAccessibiltyWarning];
    switch(returnCode) {
      case NSAlertFirstButtonReturn: {
        /* ok, ignore */
        break;
      }
      case NSAlertSecondButtonReturn:
        /* open prefs */
        [self openAccessibiltyPreferences];
        break;
      default:
        break;
    }
  }
}

- (void)openAccessibiltyPreferences {
  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]];
}

#pragma mark -
#pragma mark Autotype Invocation
- (void)performAutotypeForEntry:(KPKEntry *)entry {
  [self performAutotypeForEntry:entry overrideSequence:nil];
}
- (void)performAutotypeForEntry:(KPKEntry *)entry overrideSequence:(NSString *)sequence {
  if(entry) {
    [self _updateTargeInformationForApplication:self.previousApplication];
    [self _performAutotypeForEntry:entry];
  }
}

- (void)_didPressHotKey {
  [self _updateTargetInformationForFrontMostApplication];
  [self _performAutotypeForEntry:nil];
}

#pragma mark -
#pragma mark Actions
- (void)selectAutotypeCandiate:(MPAutotypeContext *)context {
  [self.matchSelectionWindow orderOut:self];
  self.matchSelectionWindow = nil;
  [self _performAutotypeForContext:context];
}

- (void)cancelAutotypeCandidateSelection {
  [self.matchSelectionWindow orderOut:self];
  self.matchSelectionWindow = nil;
  if(self.targetPID) {
    [self _orderApplicationToFront:self.targetPID];
  }
}

#pragma mark -
#pragma mark Autotype Execution

- (void)_performAutotypeForEntry:(KPKEntry *)entryOrNil {
  /*if(!self.autotypeSupported) {
   NSUserNotification *notification = [[NSUserNotification alloc] init];
   notification.title = NSApp.applicationName;
   notification.informativeText = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_MACPASS_HAS_NO_ACCESSIBILTY_PERMISSIONS", "Notification: Autotype failed, MacPass has no permission to send key strokes");
   notification.actionButtonTitle = NSLocalizedString(@"OPEN_PREFERENCES", "Action button in Notification to show the Accessibilty preferences");
   notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeShowAccessibiltyPreferences };
   notification.showsButtons = YES;
   [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
   return;
   }*/
  NSInteger pid = NSProcessInfo.processInfo.processIdentifier;
  if(self.targetPID == pid) {
    return; // We do not perform Autotype on ourselves
  }
  
  /* find autotype documents */
  NSArray *documents = NSApp.orderedDocuments;
  /* No open document, inform the user and return without any action */
  if(documents.count == 0) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSApp.applicationName;
    notification.informativeText = NSLocalizedString(@"AUTOTYPE_OVERLAY_NO_DOCUMENTS", "Notification: Autotype failed, no documents are open");
    notification.actionButtonTitle = NSLocalizedString(@"OPEN_DOCUMENT", "Action button in Notification to open a document");
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeAutotypeOpenDocumentRequest };
    notification.showsButtons = YES;
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
    self.userActionRequested = NSDate.date.timeIntervalSinceReferenceDate;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didUnlockDatabase:) name:MPDocumentDidUnlockDatabaseNotification object:nil];
    if (!NSApp.isActive) {
      [((MPDocumentController*)NSDocumentController.sharedDocumentController) reopenLastDocument];
      [NSApp activateIgnoringOtherApps:YES];
    }
    return; // Unlock should trigger autotype
  }
  
  NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    MPDocument *document = evaluatedObject;
    return !document.encrypted;}];
  NSArray *unlockedDocuments = [documents filteredArrayUsingPredicate:filterPredicate];
  /* We look for all unlocked documents, if all open documents are locked, we pop the front most and try to search again */
  if(unlockedDocuments.count == 0) {
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp.mainWindow makeKeyAndOrderFront:self];
    /* show the actual document window to the user */
    MPDocument *document = documents.firstObject;
    [document showWindows];
    MPDocumentWindowController *wc = document.windowControllers.firstObject;
    [wc showPasswordInputWithMessage:NSLocalizedString(@"AUTOTYPE_MESSAGE_UNLOCK_DATABASE", @"Message displayed to the user to unlock the database to perform global autotype")];
    self.userActionRequested = NSDate.date.timeIntervalSinceReferenceDate;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didUnlockDatabase:) name:MPDocumentDidUnlockDatabaseNotification object:nil];
    return; // wait for the unlock to happen
  }
  
  MPAutotypeContext *context = [self _autotypeContextForDocuments:documents forWindowTitle:self.targetWindowTitle preferredEntry:entryOrNil];
  /* TODO: that's popping up if the mulit selection dialog goes up! */
  if(self.matchSelectionWindow) {
    return; // we present the match selection window, just return
  }

  [self _performAutotypeForContext:context];
}

- (MPAutotypeContext *)_autotypeContextForDocuments:(NSArray<MPDocument *> *)documents forWindowTitle:(NSString *)windowTitle preferredEntry:(KPKEntry *)entry {
  /*
   Query the document to generate a autotype command list for the window title
   We do not care where this came form, just get the autotype commands
   */
  NSMutableArray *autotypeCandidates = [[NSMutableArray alloc] init];
  for(MPDocument *document in documents) {
    NSArray *contexts = [document autotypContextsForWindowTitle:windowTitle preferredEntry:entry];
    if(contexts ) {
      [autotypeCandidates addObjectsFromArray:contexts];
    }
  }
  NSUInteger candidates = autotypeCandidates.count;
  if(candidates == 0) {
    return nil;
  }
  if(candidates == 1 ) {
    return autotypeCandidates.lastObject;
  }
  [self _presentSelectionWindow:autotypeCandidates];
  return nil; // Nothing to do, we get called back by the window
}

- (void)_performAutotypeForContext:(MPAutotypeContext *)context {
  if(nil == context) {
    return; // No context to work with
  }
  
  if([self _orderApplicationToFront:self.targetPID]) {
    /* Sleep a bit after the app was activated */
    /* TODO - we might be able to a notification to check if the app actally was activated instead of guessing a waiting time */
    usleep(1 * NSEC_PER_MSEC);
  }
  
  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = NSApp.applicationName;
  notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeAutotypeFeedback };
  if(context) {
    notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"AUTOTYPE_OVERLAY_SINGLE_MATCH_FOR_%@", "Notification: Autotype found a single match for %@ (string placeholder)."), self.targetWindowTitle];
  } else {
    notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"AUTOTYPE_OVERLAY_NO_MATCH_FOR_%@", "Noticiation: Autotype failed to find a match for %@ (string placeholder)"), self.targetWindowTitle];
  }
  [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];

  
  for(MPAutotypeCommand *command in [MPAutotypeCommand commandsForContext:context]) {
    /* dispatch commands to main thread since most of them translate key events which is disallowed on background thread */
    dispatch_async(dispatch_get_main_queue(), ^{
      [command execute];
    });
  }
}

#pragma mark -
#pragma mark Hotkey Registration
- (void)_registerHotKey {
  if(!self.hotKeyData) {
    return;
  }
  __weak MPAutotypeDaemon *welf = self;
  DDHotKeyTask aTask = ^(NSEvent *event) {
    [welf _didPressHotKey];
  };
  self.registredHotKey = [[DDHotKeyCenter sharedHotKeyCenter] registerHotKey:[DDHotKey hotKeyWithKeyData:self.hotKeyData task:aTask]];
}

- (void)_unregisterHotKey {
  if(self.registredHotKey) {
    [[DDHotKeyCenter sharedHotKeyCenter] unregisterHotKey:self.registredHotKey];
    self.registredHotKey = nil;
  }
}

- (NSDictionary *)_infoDictionaryForApplication:(NSRunningApplication *)application {
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  NSArray *windowNumbers = [NSWindow windowNumbersWithOptions:NSWindowNumberListAllApplications];
  NSUInteger minZIndex = NSNotFound;
  NSDictionary *infoDict = nil;
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowTitle = windowDict[(NSString *)kCGWindowName];
    if(windowTitle.length <= 0) {
      continue;
    }
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(application.processIdentifier)]) {
      
      NSNumber *number = (NSNumber *)windowDict[(NSString *)kCGWindowNumber];
      NSUInteger zIndex = [windowNumbers indexOfObject:number];
      if(zIndex < minZIndex) {
        minZIndex = zIndex;
        infoDict = @{
                     kMPWindowTitleKey: windowTitle,
                     kMPProcessIdentifierKey : processId
                     };
      }
    }
  }
  return infoDict;
}

- (void)_presentSelectionWindow:(NSArray *)candidates {
  if(!self.matchSelectionWindow) {
    self.matchSelectionWindow = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                                           styleMask:NSWindowStyleMaskNonactivatingPanel|NSWindowStyleMaskTitled
                                                             backing:NSBackingStoreRetained
                                                               defer:YES];
    self.matchSelectionWindow.level = kCGAssistiveTechHighWindowLevel;
    MPAutotypeCandidateSelectionViewController *vc = [[MPAutotypeCandidateSelectionViewController alloc] init];
    vc.candidates = candidates;
    self.matchSelectionWindow.collectionBehavior |= (NSWindowCollectionBehaviorFullScreenAuxiliary |
                                                     NSWindowCollectionBehaviorMoveToActiveSpace |
                                                     NSWindowCollectionBehaviorTransient );
    self.matchSelectionWindow.contentViewController = vc;
    
  }
  if(self.targetPID) {
    [self _orderApplicationToFront:self.targetPID];
  }
  [self.matchSelectionWindow center];
  [self.matchSelectionWindow makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark MPDocument Notifications
- (void)_didUnlockDatabase:(NSNotification *)notification {
  /* Remove ourselves and call again to search matches */
  [NSNotificationCenter.defaultCenter removeObserver:self name:MPDocumentDidUnlockDatabaseNotification object:nil];
  NSTimeInterval now = NSDate.date.timeIntervalSinceReferenceDate;
  if(now - self.userActionRequested > 30) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSApp.applicationName;
    notification.informativeText = NSLocalizedString(@"AUTOTYPE_TIMED_OUT", "Notficication: Autotype timed out");
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeAutotypeFeedback };
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
  }
  else {
    [self _performAutotypeForEntry:nil];
  }
}

#pragma mark -
#pragma mark NSApplication Notifications
- (void)_didDeactivateApplication:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  self.previousApplication = userInfo[NSWorkspaceApplicationKey];
}

#pragma mark -
#pragma mark Application information
- (BOOL)_orderApplicationToFront:(pid_t)processIdentifier {
  NSRunningApplication *runingApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:processIdentifier];
  NSRunningApplication *frontApplication = NSWorkspace.sharedWorkspace.frontmostApplication;
  if(frontApplication.processIdentifier == processIdentifier) {
    return NO;
  }
  [runingApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  return YES;
}
- (void)_updateTargetInformationForFrontMostApplication {
  [self _updateTargeInformationForApplication:NSWorkspace.sharedWorkspace.frontmostApplication];
}

- (void)_updateTargeInformationForApplication:(NSRunningApplication *)application {
  if(!application) {
    self.targetPID = -1;
    self.targetWindowTitle = @"";
  }
  else {
    NSDictionary *frontApplicationInfoDict = [self _infoDictionaryForApplication:application];
    self.targetPID = [frontApplicationInfoDict[kMPProcessIdentifierKey] intValue];
    self.targetWindowTitle = frontApplicationInfoDict[kMPWindowTitleKey];
  }
}

@end
