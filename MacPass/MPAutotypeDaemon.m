//
//  MPAutotypeDaemon.m
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDaemon.h"
#import "MPDocument.h"

#import "MPDocument+Autotype.h"
#import "MPAutotypeCommand.h"
#import "MPAutotypeContext.h"
#import "MPAutotypePaste.h"

#import "MPOverlayWindowController.h"
#import "MPPasteBoardController.h"
#import "MPSettingsHelper.h"


#import "KPKEntry.h"

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
- (instancetype)init {
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
  NSMenuItem *item = [self.matchSelectionButton selectedItem];
  MPAutotypeContext *context = [item representedObject];
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
  NSInteger pid = [[NSProcessInfo processInfo] processIdentifier];
  if(self.targetPID == pid) {
    return; // We do not perform Autotype on ourselves
  }
  
  MPDocument *document = [self _findAutotypeDocument];
  if(!document) {
    /* We do not have a document. This can be
     a) there is none - nothing happens
     b) there is at least one, but locked - we get called again after the document has been unlocked
     */
    return;
  }
  
  MPAutotypeContext *context = [self _autotypeContextInDocument:document forWindowTitle:self.targetWindowTitle preferredEntry:entryOrNil];
  /* TODO: that's popping up if the mulit seleciton dialog goes up! */
  if(!entryOrNil) {
    NSImage *appIcon = [[NSApplication sharedApplication] applicationIconImage];
    NSString *label = context ? NSLocalizedString(@"AUTOTYPE_OVERLAY_SINGLE_MATCH", "") : NSLocalizedString(@"AUTOTYPE_OVERLAY_NO_MATCH", "");
    [[MPOverlayWindowController sharedController] displayOverlayImage:appIcon label:label atView:nil];
  }
  [self _performAutotypeForContext:context];
}

- (MPDocument *)_findAutotypeDocument {
  NSArray *documents = [NSApp orderedDocuments];
  MPDocument *currentDocument = nil;
  for(MPDocument *openDocument in documents) {
    if(NO == openDocument.encrypted) {
      currentDocument = openDocument;
      break;
    }
  }
  BOOL hasOpenDocuments = [documents count] > 0;
  if(!currentDocument && hasOpenDocuments) {
    [NSApp activateIgnoringOtherApps:YES];
    [[NSApp mainWindow] makeKeyAndOrderFront:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didUnlockDatabase:) name:MPDocumentDidUnlockDatabaseNotification object:nil];
  }
  return currentDocument;
}

- (MPAutotypeContext *)_autotypeContextInDocument:(MPDocument *)document forWindowTitle:(NSString *)windowTitle preferredEntry:(KPKEntry *)entry {
  /*
   Query the document to generate a autotype command list for the window title
   We do not care where this came form, just get the autotype commands
   */
  NSArray *autotypeCandidates = [document autotypContextsForWindowTitle:windowTitle preferredEntry:entry];
  NSUInteger candidates = [autotypeCandidates count];
  if(candidates == 0) {
    return nil;
  }
  if(candidates == 1 ) {
    return  [autotypeCandidates lastObject];
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
    /* TODO - we can use a saver way and use a notification to chekc if the app actally was activated */
    usleep(1 * NSEC_PER_MSEC);
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *commands = [MPAutotypeCommand commandsForContext:context];
    for(MPAutotypeCommand *command in commands) {
      [command execute];
    }
  });
}

#pragma mark -
#pragma mark Hotkey Registration
- (void)_registerHotKey {
  __weak MPAutotypeDaemon *welf = self;
  DDHotKeyTask aTask = ^(NSEvent *event) {
    [welf _didPressHotKey];
  };
  DDHotKey *storedHotkey;
  if(nil == self.hotKeyData) {
    storedHotkey = [DDHotKey defaultHotKeyWithTask:aTask];
  }
  else {
    storedHotkey = [[DDHotKey alloc] initWithKeyData:self.hotKeyData task:aTask];
  }
  self.registredHotKey = [[DDHotKeyCenter sharedHotKeyCenter] registerHotKey:storedHotkey];
}

- (void)_unregisterHotKey {
  if(nil != self.registredHotKey) {
    [[DDHotKeyCenter sharedHotKeyCenter] unregisterHotKey:self.registredHotKey];
    self.registredHotKey = nil;
  }
}

- (NSDictionary *)_infoDictionaryForApplication:(NSRunningApplication *)application {
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowTitle = windowDict[(NSString *)kCGWindowName];
    if([windowTitle length] <= 0) {
      continue;
    }
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(application.processIdentifier)]) {
      return @{
               kMPWindowTitleKey: windowDict[(NSString *)kCGWindowName],
               kMPProcessIdentifierKey : processId
               };
    }
  }
  return nil;
}

- (void)_presentSelectionWindow:(NSArray *)candidates {
  if(!self.matchSelectionWindow) {
    [[NSBundle mainBundle] loadNibNamed:@"AutotypeCandidateSelectionWindow" owner:self topLevelObjects:nil];
    [self.matchSelectionWindow setLevel:NSFloatingWindowLevel];
  }
  NSMenu *associationMenu = [[NSMenu alloc] init];
  [associationMenu addItemWithTitle:NSLocalizedString(@"SELECT_AUTOTYPE_CANDIDATE", "") action:NULL keyEquivalent:@""];
  [associationMenu addItem:[NSMenuItem separatorItem]];
  [associationMenu setAutoenablesItems:NO];
  for(MPAutotypeContext *context in candidates) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:context.entry.title action:0 keyEquivalent:@""];
    [item setRepresentedObject:context];
    [associationMenu addItem:item];
    NSArray *attributes = (context.entry.username.length > 0 )
    ? @[ context.entry.username, context.command ]
    : @[ context.command ];
    
    for(NSString *value in attributes) {
      NSMenuItem *valueItem  = [[NSMenuItem alloc] initWithTitle:value action:NULL keyEquivalent:@""];
      [valueItem setIndentationLevel:1];
      [valueItem setEnabled:NO];
      [associationMenu addItem:valueItem];
    }
  }
  [self.matchSelectionButton setMenu:associationMenu];
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
  NSRunningApplication *frontApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
  if(frontApplication.processIdentifier == processIdentifier) {
    return NO;
  }
  [runingApplication activateWithOptions:0];
  return YES;
}
- (void)_updateTargetInfoForFrontMostApplication {
  [self _updateTargeInformationForApplication:[[NSWorkspace sharedWorkspace] frontmostApplication]];
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
