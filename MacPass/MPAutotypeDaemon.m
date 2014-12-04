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
@property (assign) pid_t targetPID;
@property (copy) NSString *targetWindowTitle;

@end

@implementation MPAutotypeDaemon

#pragma mark -
#pragma mark Lifecylce

- (id)init {
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
  }
  return self;
}

- (void)dealloc {
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
#pragma mark Actions

- (void)executeAutotypeWithSelectedMatch:(id)sender {
  NSMenuItem *item = [self.matchSelectionButton selectedItem];
  MPAutotypeContext *context = [item representedObject];
  [self.matchSelectionWindow orderOut:self];
  [self _performAutotypeForContext:context];
}

- (void)cancelAutotypeSelection:(id)sender {
  [self.matchSelectionWindow orderOut:sender];
  if(self.targetPID) {
    [MPAutotypeDaemon _orderApplicationToFront:self.targetPID];
  }
}

#pragma mark -
#pragma mark Hotkey evaluation

- (void)_didPressHotKey {
  [self _performAutotypeUsingCurrentWindowAndApplication:YES];
}

- (void)_performAutotypeUsingCurrentWindowAndApplication:(BOOL)useCurrentWindowAndApplication {
  if(useCurrentWindowAndApplication) {
    [self _updateTargetApplicationAndWindow];
  }
  
  MPDocument *document = [self _findAutotypeDocument];
  if(!document) {
    return; // nothing to do
  }
  
  MPAutotypeContext *context = [self _autotypeContextInDocument:document forWindowTitle:self.targetWindowTitle];
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

- (MPAutotypeContext *)_autotypeContextInDocument:(MPDocument *)document forWindowTitle:(NSString *)windowTitle {
  /*
   Query the document to generate a autotype command list for the window title
   We do not care where this came form, just get the autotype commands
   */
  NSArray *autotypeCandidates = [document autotypContextsForWindowTitle:windowTitle];
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
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *commands = [MPAutotypeCommand commandsForContext:context];
    if([MPAutotypeDaemon _orderApplicationToFront:self.targetPID]) {
      /* Sleep a bit after the app was activated */
      usleep(0.5 * NSEC_PER_MSEC);
    }
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

- (NSDictionary *)_frontMostApplicationInfoDict {
  NSRunningApplication *frontApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
  
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowTitle = windowDict[(NSString *)kCGWindowName];
    if([windowTitle length] <= 0) {
      continue;
    }
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(frontApplication.processIdentifier)]) {
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
  /* Setup Items in Popup */
}

#pragma mark -
#pragma mark MPDocument Notifications

- (void)_didUnlockDatabase:(NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self _performAutotypeUsingCurrentWindowAndApplication:NO];
}

#pragma mark -
#pragma mark Application information

+ (BOOL)_orderApplicationToFront:(pid_t)processIdentifier {
  NSRunningApplication *runingApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:processIdentifier];
  NSRunningApplication *frontApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
  if(frontApplication.processIdentifier == processIdentifier) {
    return NO;
  }
  [runingApplication activateWithOptions:0];
  return YES;
}

- (void)_updateTargetApplicationAndWindow {
  /*
   Determine the window title of  the current front most application
   Start searching the db for the best fit (based on title, then on window associations
   */
  NSDictionary *frontApplicationInfoDict = [self _frontMostApplicationInfoDict];
  self.targetPID = [frontApplicationInfoDict[kMPProcessIdentifierKey] intValue];
  self.targetWindowTitle = frontApplicationInfoDict[kMPWindowTitleKey];
}

@end
