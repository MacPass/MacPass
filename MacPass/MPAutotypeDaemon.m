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
#import "MPAutotypeEnvironment.h"
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

@interface MPAutotypeDaemon ()

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) NSData *hotKeyData;
@property (strong) DDHotKey *registredHotKey;

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
    MPAutotypeEnvironment *env = [MPAutotypeEnvironment environmentWithTargetApplication:self.previousApplication entry:entry overrideSequence:sequence];
    [self _runAutotypeWithEnvironment:env];
  }
}

- (void)_didPressHotKey {
  MPAutotypeEnvironment *env = [MPAutotypeEnvironment environmentWithTargetApplication:NSWorkspace.sharedWorkspace.frontmostApplication entry:nil overrideSequence:nil];
  [self _runAutotypeWithEnvironment:env];
}

#pragma mark -
#pragma mark Autotype Execution
- (void)selectAutotypeContext:(MPAutotypeContext *)context forEnvironment:(MPAutotypeEnvironment *)environment {
  [self.matchSelectionWindow orderOut:self];
  self.matchSelectionWindow = nil;
  [self _runAutotypeWithEnvironment:environment forContext:context];
  if(environment.hidden) {
    [NSApplication.sharedApplication hide:nil];
  }
}

- (void)cancelAutotypeContextSelectionForEnvironment:(MPAutotypeEnvironment *)environment {
  [self.matchSelectionWindow orderOut:self];
  self.matchSelectionWindow = nil;
  if(environment.hidden) {
    [NSApplication.sharedApplication hide:nil];
  }
  if(environment.pid) {
    [self _orderApplicationToFront:environment.pid completionHandler:nil];
  }
}

- (void)_runAutotypeAfterDatabaseUnlockWithEnvironment:(MPAutotypeEnvironment *)environment requestedAt:(NSTimeInterval)requestTime {
  NSTimeInterval now = NSDate.date.timeIntervalSinceReferenceDate;
  if(now - requestTime > 30) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_TIMED_OUT_TITLE", "Title for the notification when the Autotype operation timed out");
    notification.informativeText = NSLocalizedString(@"AUTOTYPE_TIMED_OUT", "Notficication: Autotype timed out");
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeAutotypeFeedback };
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
  }
  else {
    [self _runAutotypeWithEnvironment:environment];
  }
}

- (void)_runAutotypeWithEnvironment:(MPAutotypeEnvironment *)env {
  if(env.isSelfTargeting) {
    return; // we do not want to target ourselves
  }
  
  if(!self.hasNecessaryAutotypePermissions) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_PERMISSIONS_MISSING_TITLE", "Title for autotype feedback on missing permissions");
    notification.informativeText = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_MACPASS_IS_MISSING_PERMISSIONS", "Notification: Autotype failed, MacPass has not enough permissions to perform autotype");
    notification.actionButtonTitle = NSLocalizedString(@"SHOW_AUTOTYPE_DOCTOR", "Action button in Notification to show the Autotype Doctor");
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeRunAutotypeDoctor };
    notification.showsButtons = YES;
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
    return;
  }
  
  /* find autotype documents */
  NSArray *documents = NSApp.orderedDocuments;
  /* No open document, inform the user and return without any action */
  if(documents.count == 0) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_NO_DOCUMENTS_TITLE", "Notification: Title for autotype feedback");
    notification.informativeText = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_NO_DOCUMENTS_INFORMATIVE_TEXT", "Notification: Autotype failed, no documents are open");
    notification.actionButtonTitle = NSLocalizedString(@"OPEN_DOCUMENT", "Action button in Notification to open a document");
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeAutotypeOpenDocumentRequest };
    notification.showsButtons = YES;
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
    NSNotificationCenter * __weak nc = [NSNotificationCenter defaultCenter];
    MPAutotypeDaemon * __weak welf = self;
    NSTimeInterval requestTime = NSDate.date.timeIntervalSinceReferenceDate;
    id __block unlockToken = [nc addObserverForName:MPDocumentDidUnlockDatabaseNotification
                                             object:nil
                                              queue:NSOperationQueue.mainQueue
                                         usingBlock:^(NSNotification *notification) {
      [welf _runAutotypeAfterDatabaseUnlockWithEnvironment:env requestedAt:requestTime];
      [nc removeObserver:unlockToken];
    }];
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
    NSNotificationCenter * __weak nc = [NSNotificationCenter defaultCenter];
    MPAutotypeDaemon * __weak welf = self;
    NSTimeInterval requestTime = NSDate.date.timeIntervalSinceReferenceDate;
    id __block unlockToken = [nc addObserverForName:MPDocumentDidUnlockDatabaseNotification
                                             object:nil
                                              queue:NSOperationQueue.mainQueue
                                         usingBlock:^(NSNotification *notification) {
      [welf _runAutotypeAfterDatabaseUnlockWithEnvironment:env requestedAt:requestTime];
      
      [nc removeObserver:unlockToken];
    }];
    return; // wait for the unlock to happen
  }
  
  MPAutotypeContext *context = [self _autotypeContextForDocuments:documents withEnvironment:env];
  if(self.matchSelectionWindow) {
    return; // we present the match selection window, just return
  }
  if(!env.preferredEntry) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSLocalizedString(@"AUTOTYPE_NOTIFICATION_MATCH_TITLE", "Notification: Title for autotype feedback");
    notification.userInfo = @{ MPUserNotificationTypeKey: MPUserNotificationTypeAutotypeFeedback };
    if(context) {
      notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"AUTOTYPE_NOTIFICATION_SINGLE_MATCH_FOR_%@", "Notification: Autotype found a single match for %@ (string placeholder)."), env.windowTitle];
    }
    else {
      notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"AUTOTYPE_NOTIFICATION_NO_MATCH_FOR_%@", "Noticiation: Autotype failed to find a match for %@ (string placeholder)"), env.windowTitle];
    }
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
  }
  [self _runAutotypeWithEnvironment:env forContext:context];
}

- (MPAutotypeContext *)_autotypeContextForDocuments:(NSArray<MPDocument *> *)documents withEnvironment:(MPAutotypeEnvironment *)environment {
  /*
   Query the document to generate a autotype command list for the window title
   We do not care where this came form, just get the autotype commands
   */
  NSMutableArray *autotypeCandidates = [[NSMutableArray alloc] init];
  for(MPDocument *document in documents) {
    NSArray *contexts = [document autotypContextsForWindowTitle:environment.windowTitle preferredEntry:environment.preferredEntry];
    if(contexts ) {
      [autotypeCandidates addObjectsFromArray:contexts];
    }
  }

  BOOL isGlobalAutotype = (environment.preferredEntry == nil);
  BOOL alwaysShowCandidateSelection = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyGloablAutotypeAlwaysShowCandidateSelection];
  
  /* if we have only one candidate and do not need to show the windows, return only the last candiadate */
  if(autotypeCandidates.count <= 1 && !(isGlobalAutotype && alwaysShowCandidateSelection)) {
      return autotypeCandidates.lastObject;
  }
  /* otherwise show the candidate selection window */
  [self _presentCandiadates:autotypeCandidates forEnvironment:environment];
  return nil; // Nothing to do, we get called back by the window
}

- (void)_runAutotypeWithEnvironment:(MPAutotypeEnvironment *)environment forContext:(MPAutotypeContext *)context {
  if(nil == environment) {
    return; // no Environment to work in
  }
  if(nil == context) {
    return; // No context to work with
  }
  __weak MPAutotypeDaemon *welf = self;
  BOOL appIsFrontmost = [self _orderApplicationToFront:environment.pid completionHandler:^{
    [welf _runAutotypeWithEnvironment:environment forContext:context];
  }];
  if(!appIsFrontmost) {
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
      /* re-hide after every command since this might have put us back up front */
      if(environment.hidden) {
        [NSApplication.sharedApplication hide:nil];
      }
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

- (void)_presentCandiadates:(NSArray *)candidates forEnvironment:(MPAutotypeEnvironment *)environment {
  if(!self.matchSelectionWindow) {
    self.matchSelectionWindow = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                                           styleMask:NSWindowStyleMaskResizable|NSWindowStyleMaskNonactivatingPanel|NSWindowStyleMaskTitled
                                                             backing:NSBackingStoreBuffered
                                                               defer:YES];
    self.matchSelectionWindow.level = kCGAssistiveTechHighWindowLevel;
    MPAutotypeCandidateSelectionViewController *vc = [[MPAutotypeCandidateSelectionViewController alloc] init];
    vc.candidates = candidates;
    vc.environment = environment;
    self.matchSelectionWindow.collectionBehavior |= (NSWindowCollectionBehaviorFullScreenAuxiliary |
                                                     NSWindowCollectionBehaviorMoveToActiveSpace |
                                                     NSWindowCollectionBehaviorTransient );
    self.matchSelectionWindow.contentViewController = vc;
    
  }
  [self.matchSelectionWindow center];
  [self.matchSelectionWindow makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark NSApplication Notifications
- (void)_didDeactivateApplication:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  self.previousApplication = userInfo[NSWorkspaceApplicationKey];
}

#pragma mark -
#pragma mark Application information
//- (BOOL)_orderApplicationToFront:(pid_t)processIdentifier inEnvironment:(MPAutotypeEnvironment *) environment {
- (BOOL)_orderApplicationToFront:(pid_t)processIdentifier completionHandler:(void (^_Nullable)(void))completionHandler {
  NSRunningApplication *runingApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:processIdentifier];
  NSRunningApplication *frontApplication = NSWorkspace.sharedWorkspace.frontmostApplication;
  if(frontApplication.processIdentifier == processIdentifier) {
    return YES;
  }

  NSNotificationCenter * __weak nc = NSWorkspace.sharedWorkspace.notificationCenter;
  id __block didActivateToken = [nc addObserverForName:NSWorkspaceDidActivateApplicationNotification
                                           object:nil
                                            queue:NSOperationQueue.mainQueue
                                       usingBlock:^(NSNotification *notification) {
    [nc removeObserver:didActivateToken];
    if(completionHandler) {
      completionHandler();
    }
  }];
  [runingApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  return NO;
}
@end
