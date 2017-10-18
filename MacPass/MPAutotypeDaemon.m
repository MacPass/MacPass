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

#import "MPAutotypeCommand.h"
#import "MPAutotypeContext.h"
#import "MPAutotypePaste.h"

#import "MPPasteBoardController.h"
#import "MPSettingsHelper.h"

#import "NSApplication+MPAdditions.h"

#import "KeePassKit/KeePassKit.h"

#import "DDHotKeyCenter.h"
#import "DDHotKey+MacPassAdditions.h"

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
    [self bind:NSStringFromSelector(@selector(enabled))
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableGlobalAutotype]
       options:nil];
    
    [self bind:NSStringFromSelector(@selector(hotKeyData))
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyGlobalAutotypeKeyDataKey]
       options:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(_didDeactivateApplication:)
                                                               name:NSWorkspaceDidDeactivateApplicationNotification
                                                             object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
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

#pragma mark -
#pragma mark Autotype Invocation
- (void)performAutotypeForEntry:(KPKEntry *)entry {
  if(entry) {
    [self _updateTargeInformationForApplication:self.previousApplication];
    [self _performAutotypeForEntry:entry];
  }
}

- (void)_didPressHotKey {
  [self _updateTargetInfoForFrontMostApplication];
  [self _performAutotypeForEntry:nil];
}

#pragma mark -
#pragma mark Actions
- (void)performAutotypeWithSelectedMatch:(id)sender {
  NSMenuItem *item = self.matchSelectionButton.selectedItem;
  MPAutotypeContext *context = item.representedObject;
  [self.matchSelectionWindow orderOut:self];
  [self _performAutotypeForContext:context];
}

- (void)cancelAutotypeSelection:(id)sender {
  [self.matchSelectionWindow orderOut:sender];
  if(self.targetPID) {
    [self _orderApplicationToFront:self.targetPID];
  }
}

#pragma mark -
#pragma mark Autotype Execution

- (void)_performAutotypeForEntry:(KPKEntry *)entryOrNil {
  NSInteger pid = [NSProcessInfo processInfo].processIdentifier;
  if(self.targetPID == pid) {
    return; // We do not perform Autotype on ourselves
  }
  
  /* find autotype documents */
  NSArray *documents = [NSApp orderedDocuments];
  /* No open document, inform the user and return without any action */
  if(documents.count == 0) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSApp.applicationName;
    notification.informativeText = NSLocalizedString(@"AUTOTYPE_OVERLAY_NO_DOCUMENTS", "");
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    return;
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
    [documents.firstObject showWindows];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didUnlockDatabase:) name:MPDocumentDidUnlockDatabaseNotification object:nil];
    return; // wait for the unlock to happen
  }
  
  MPAutotypeContext *context = [self _autotypeContextForDocuments:documents forWindowTitle:self.targetWindowTitle preferredEntry:entryOrNil];
  /* TODO: that's popping up if the mulit selection dialog goes up! */
  if(!entryOrNil) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSApp.applicationName;
    if(context) {
      notification.informativeText = NSLocalizedString(@"AUTOTYPE_OVERLAY_SINGLE_MATCH", "");
    }
    else {
      notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"AUTOTYPE_OVERLAY_NO_MATCH_FOR_%@", ""), self.targetWindowTitle];
    }
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
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
    /* TODO - we can use a saver way and use a notification to check if the app actally was activated */
    usleep(1 * NSEC_PER_MSEC);
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray<MPAutotypeCommand *> *commands = [MPAutotypeCommand commandsForContext:context];
    for(MPAutotypeCommand *command in commands) {
      [command execute];
    }
  });
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
    [[NSBundle mainBundle] loadNibNamed:@"AutotypeCandidateSelectionWindow" owner:self topLevelObjects:nil];
    self.matchSelectionWindow.level = NSFloatingWindowLevel;
  }
  NSMenu *associationMenu = [[NSMenu alloc] init];
  [associationMenu addItemWithTitle:NSLocalizedString(@"SELECT_AUTOTYPE_CANDIDATE", "") action:NULL keyEquivalent:@""];
  [associationMenu addItem:[NSMenuItem separatorItem]];
  associationMenu.autoenablesItems = NO;
  for(MPAutotypeContext *context in candidates) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:context.entry.title action:0 keyEquivalent:@""];
    [item setRepresentedObject:context];
    [associationMenu addItem:item];
    NSArray *attributes = (context.entry.username.length > 0 )
    ? @[ context.entry.username, context.command ]
    : @[ context.command ];
    
    for(NSString *value in attributes) {
      NSMenuItem *valueItem  = [[NSMenuItem alloc] initWithTitle:value action:NULL keyEquivalent:@""];
      valueItem.indentationLevel = 1;
      valueItem.enabled = NO;
      [associationMenu addItem:valueItem];
    }
  }
  self.matchSelectionButton.menu = associationMenu;
  [self.matchSelectionWindow makeKeyAndOrderFront:self];
  [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark -
#pragma mark MPDocument Notifications
- (void)_didUnlockDatabase:(NSNotification *)notification {
  /* Remove ourselves and call again to search matches */
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self _performAutotypeForEntry:nil];
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
  NSRunningApplication *frontApplication = [NSWorkspace sharedWorkspace].frontmostApplication;
  if(frontApplication.processIdentifier == processIdentifier) {
    return NO;
  }
  [runingApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  return YES;
}
- (void)_updateTargetInfoForFrontMostApplication {
  [self _updateTargeInformationForApplication:[NSWorkspace sharedWorkspace].frontmostApplication];
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
