//
//  MPAutotypeDaemon.m
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDaemon.h"
#import "DDHotKeyCenter.h"
#import "MPPasteBoardController.h"
#import "MPDocument.h"
#import "MPDocument+Autotype.h"
#import "MPAutotypeCommand.h"
#import "MPSettingsHelper.h"

#import "KPKEntry.h"

#import <Carbon/Carbon.h>

NSString *const kMPWindowTitleKey = @"windowTitle";
NSString *const kMPApplciationNameKey = @"applicationName";

@interface MPAutotypeDaemon ()

@property (nonatomic, assign) BOOL enabled;

@end

@implementation MPAutotypeDaemon

- (id)init {
  self = [super init];
  if (self) {
    _enabled = NO;
    [[NSUserDefaults standardUserDefaults] bind:kMPSettingsKeyEnableGlobalAutotype toObject:self withKeyPath:@"enabled" options:nil];
  }
  return self;
}

#pragma mark Properties
- (void)setEnabled:(BOOL)enabled {
  if(_enabled != enabled) {
    _enabled = enabled;
    self.enabled ? [self _registerHotKey] : [self _unregisterHotKey];
  }
}

- (void)exectureAutotypeForEntry:(KPKEntry *)entry withWindowTitle:(NSString *)title {
  NSAssert(NO,@"Not Implemented");
}

- (void)executeAutotypeWithSelectedMatch:(id)sender {
  NSMenuItem *item = [self.matchSelectionButton selectedItem];
  MPAutotypeContext *context = [item representedObject];
}

- (void)_didPressHotKey {
  NSArray *documents = [NSApp orderedDocuments];
  MPDocument *currentDocument = nil;
  for(MPDocument *openDocument in documents) {
    if(NO == openDocument.encrypted) {
      currentDocument = openDocument;
      break;
    }
  }
  if(currentDocument.encrypted) {
    return; // No need to search in closed documents
  }
  /*
   Determine the window title of  the current front most application
   Start searching the db for the best fit (based on title, then on window associations
   */
  NSDictionary *frontApplicationInfoDict = [self _frontMostApplicationInfoDict];
  NSString *windowTitle = frontApplicationInfoDict[kMPWindowTitleKey];
  NSString *applicationName = frontApplicationInfoDict[kMPApplciationNameKey];
  NSLog(@"Looking for entries matching window title:%@ of applciation: %@", windowTitle, applicationName);
  
  /*
   Query the document to generate a autotype command list for the window title
   We do not care where this came form, just get the autotype commands
   */
  NSArray *autotypeCandidates = [currentDocument autotypContextsForWindowTitle:windowTitle];
  NSUInteger candiates = [autotypeCandidates count];
  if(candiates == 0) {
    return; // No Entries found.
  }
  if(candiates > 1) {
    [self _presentSelectionWindow];
    return; // Nothing to do, we get called back by the window
  }
  /* Just in case it's not there anymore, order the app for the window we want to autotype back to the foreground! */
  [self _orderApplicationToFront:applicationName];
  /*
   Implement!
   */
  return;
  
  KPKEntry *selectedEntry = currentDocument.selectedEntry;
  if(nil == currentDocument || nil == selectedEntry) {
    return; // no open documents, no selected entry
  }
  
  /* TODO:
   Replace entry based palce holders
   Replace global placeholders
   Translate to paste/copy commands
   Find correct key-codes for current keyboard layout to perform paste command
   */
}

- (void)_registerHotKey {
  [[DDHotKeyCenter sharedHotKeyCenter] registerHotKeyWithKeyCode:kVK_ANSI_M
                                                   modifierFlags:(NSCommandKeyMask | NSAlternateKeyMask )
                                                          target:self
                                                          action:@selector(_didPressHotKey)
                                                          object:nil];
}

- (void)_unregisterHotKey {
  [[DDHotKeyCenter sharedHotKeyCenter] unregisterHotKeysWithTarget:self action:@selector(_didPressHotKey)];
}

- (NSDictionary *)_frontMostApplicationInfoDict {
  NSRunningApplication *frontApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
  NSString *name = frontApplication.localizedName;
  
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  for(NSDictionary *windowDict in currentWindows) {
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(frontApplication.processIdentifier)]) {
      return @{
               kMPWindowTitleKey:windowDict[(NSString *)kCGWindowName],
               kMPApplciationNameKey : name
               };
    }
  }
  return nil;
}

- (void)_presentSelectionWindow {
  if(!self.matchSelectionWindow) {
    [[NSBundle mainBundle] loadNibNamed:@"AutotypeCandidateSelectionWindow" owner:self topLevelObjects:nil];
    [self.performAutotypeButton setTarget:self];
    [self.performAutotypeButton setAction:@selector(executeAutotypeWithSelectedMatch:)];
  }
  [self.matchSelectionWindow makeKeyAndOrderFront:self];
  /* Setup Items in Popup */
}

- (void)_orderApplicationToFront:(NSString *)applicationName {
  NSString *appleScript = [[NSString alloc] initWithFormat:@"activate application %@", applicationName];
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:appleScript];
  NSDictionary *error;
  [script executeAndReturnError:&error];
}


@end
