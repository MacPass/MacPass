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
#import "MPAutotypeDelay.h"
#import "MPPasteBoardController.h"
#import "MPSettingsHelper.h"
#import "MPAutotypeCandidateSelectionViewController.h"
#import "MPUserNotificationCenterDelegate.h"
#import "MPAutotypeDoctor.h"

#import "MPPluginHost.h"
#import "MPPlugin.h"

#import "NSApplication+MPAdditions.h"
#import "NSUserNotification+MPAdditions.h"

#import "DDHotKeyCenter.h"
#import "DDHotKey+MacPassAdditions.h"

#import "KeePassKit/KeePassKit.h"
#import <Carbon/Carbon.h>

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
@property (strong) id applicationActivationObserver;
@property (nonatomic, readonly) BOOL hasNecessaryAutotypePermissions;
@end

@implementation MPAutotypeDaemon

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
  if(self.applicationActivationObserver) {
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self.applicationActivationObserver name:NSWorkspaceDidActivateApplicationNotification object:nil];
  }
  [self unbind:NSStringFromSelector(@selector(enabled))];
  [self unbind:NSStringFromSelector(@selector(hotKeyData))];
}

#pragma mark -
#pragma mark Properties

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

- (BOOL)hasNecessaryAutotypePermissions {
  return MPAutotypeDoctor.defaultDoctor.hasNecessaryAutotypePermissions;
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
    [self _orderApplicationToFront:self.targetPID forContext:nil];
  }
}

#pragma mark -
#pragma mark Autotype Execution

- (void)_performAutotypeForEntry:(KPKEntry *)entryOrNil {
  if(!self.hasNecessaryAutotypePermissions) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSApp.applicationName;
    notification.informativeText = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_MACPASS_IS_MISSING_PERMISSIONS", "Notification: Autotype failed, MacPass has not enough permissions to perform autotype");
    notification.actionButtonTitle = NSLocalizedString(@"SHOW_AUTOTYPE_DOCTOR", "Action button in Notification to show the Autotype Doctor");
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeRunAutotypeDoctor };
    notification.showsButtons = YES;
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
    return;
  }
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
    return; // Unlock should trigger autotype
  }
  
  NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    MPDocument *document = evaluatedObject;
    return !document.encrypted;
  }];
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
  /* TODO: that's popping up if the multi selection dialog goes up! */
  if(self.matchSelectionWindow) {
    return; // we present the match selection window, just return
  }
  if(!entryOrNil) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSApp.applicationName;
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeAutotypeFeedback };
    if(context) {
      notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"AUTOTYPE_OVERLAY_SINGLE_MATCH_FOR_%@", "Notification: Autotype found a single match for %@ (string placeholder)."), self.targetWindowTitle];
    }
    else {
      notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"AUTOTYPE_OVERLAY_NO_MATCH_FOR_%@", "Noticiation: Autotype failed to find a match for %@ (string placeholder)"), self.targetWindowTitle];
    }
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
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
  [self _presentCandiadates:autotypeCandidates forWindowTitle:windowTitle];
  return nil; // Nothing to do, we get called back by the window
}

- (void)_performAutotypeForContext:(MPAutotypeContext *)context {
  if(nil == context) {
    return; // No context to work with
  }
  
  if(NO == [self _orderApplicationToFront:self.targetPID forContext:(MPAutotypeContext *)context]) {
    return; // We will get called back when the application is in front - hopfully
  }
  
  useconds_t globalDelay = 0;
  for(MPAutotypeCommand *command in [MPAutotypeCommand commandsForContext:context]) {
    /*
     FIXME: Introduce a global state for execution to allow command to set state value
     e.g. [command executeWithContext:(MPCommandExectionContext *)context]
     and inside the command set the sate e.g. context.delay = myDelay
     then use this state in the command scheduling to set the global delay
     */
    if([command isKindOfClass:MPAutotypeDelay.class]) {
      MPAutotypeDelay *delayCommand = (MPAutotypeDelay *)command;
      if(delayCommand.isGlobal) {
        globalDelay = (useconds_t)delayCommand.delay;
      }
    }
    /* dispatch commands to main thread since most of them translate key events which is disallowed on background thread */
    dispatch_async(dispatch_get_main_queue(), ^{
      if(globalDelay > 0) {
        usleep(globalDelay*NSEC_PER_USEC);
      }
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
  if(currentWindows.count > 0 && infoDict.count == 0) {
    // show some information about not being able to determine any windows
    NSLog(@"Unable to retrieve any window names. If you encounter this issue you might be running 10.15 and MacPass has no permission for screen recording.");
  }
  return infoDict;
}

- (void)_presentCandiadates:(NSArray *)candidates forWindowTitle:(NSString *)windowTitle {
  if(!self.matchSelectionWindow) {
    self.matchSelectionWindow = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                                           styleMask:NSWindowStyleMaskNonactivatingPanel|NSWindowStyleMaskTitled
                                                             backing:NSBackingStoreRetained
                                                               defer:YES];
    self.matchSelectionWindow.level = kCGAssistiveTechHighWindowLevel;
    MPAutotypeCandidateSelectionViewController *vc = [[MPAutotypeCandidateSelectionViewController alloc] init];
    vc.candidates = candidates;
    vc.windowTitle = windowTitle;
    self.matchSelectionWindow.collectionBehavior |= (NSWindowCollectionBehaviorFullScreenAuxiliary |
                                                     NSWindowCollectionBehaviorMoveToActiveSpace |
                                                     NSWindowCollectionBehaviorTransient );
    self.matchSelectionWindow.contentViewController = vc;
    
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
- (BOOL)_orderApplicationToFront:(pid_t)processIdentifier forContext:(MPAutotypeContext *)context {
  NSRunningApplication *runingApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:processIdentifier];
  NSRunningApplication *frontApplication = NSWorkspace.sharedWorkspace.frontmostApplication;
  if(frontApplication.processIdentifier == processIdentifier) {
    return YES;
  }
  
  /* cleanup before to make sure everything is top notch */
  if(self.applicationActivationObserver) {
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self.applicationActivationObserver name:NSWorkspaceDidActivateApplicationNotification object:nil];
    self.applicationActivationObserver = nil;
  }
  
  self.applicationActivationObserver = [NSWorkspace.sharedWorkspace.notificationCenter addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
    if(self.applicationActivationObserver) {
      [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self.applicationActivationObserver name:NSWorkspaceDidActivateApplicationNotification object:nil];
    }
    [self _performAutotypeForContext:context];
  }];
  
  [runingApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  return NO;
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
    
    /* if we have any resolvers, let them provide the window title */
    NSArray *resolvers = [MPPluginHost.sharedHost windowTitleResolverForRunningApplication:application];
    for(MPPlugin<MPAutotypeWindowTitleResolverPlugin> *resolver in resolvers) {
      NSString *windowTitle = [resolver windowTitleForRunningApplication:application];
      if(windowTitle.length > 0) {
        self.targetWindowTitle = windowTitle;
        break;
      }
    }
  }
}

@end
