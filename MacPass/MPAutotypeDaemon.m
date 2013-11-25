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

#import "KPKEntry.h"

#import <Carbon/Carbon.h>

@implementation MPAutotypeDaemon

- (id)init {
  self = [super init];
  if (self) {
    /*
     Test the system for enabled access for assistive devices. Otherwise we cannot work properly
     
     Use defaults to determine if global hotkey is enabled
    [self _registerHotKey];
     */
  }
  return self;
}

- (void)didPressHotKey {
  // copy items to pasteboard
  NSArray *documents = [NSApp orderedDocuments];
  MPDocument *currentDocument = nil;
  for(MPDocument *openDocument in documents) {
    if(NO == openDocument.encrypted) {
      currentDocument = openDocument;
      break;
    }
  }
  
  /*
   Determine the window title of  the current front most application
   Start searching the db for the best fit (based on title, then on window associations
   */
  NSString *windowTitle = [self _frontMostWindowTitle];
  NSLog(@"Looking for entries matching window title:%@", windowTitle);
  
  /*
   Query the document to generate a autotype command list for the window title
   We do not care where this came form, just get the autotype commands
   */
  NSArray *autotypeCandidates = [[currentDocument findEntriesForWindowTitle:windowTitle] lastObject];
  NSUInteger candiates = [autotypeCandidates count];
  if(candiates == 0) {
    return; // No Entries found.
  }
  
  if(candiates > 1) {
    // open Dialog to select from possible entries
  }
  
  
  
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
                                                          action:@selector(didPressHotKey)
                                                          object:nil];
}

- (NSString *)_frontMostWindowTitle {
  NSRunningApplication *frontApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
  
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  for(NSDictionary *windowDict in currentWindows) {
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(frontApplication.processIdentifier)]) {
      return windowDict[(NSString *)kCGWindowName];
    }
  }
  return nil;
}

@end
