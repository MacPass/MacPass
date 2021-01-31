//
//  NSRunningApplication+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 15.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "NSRunningApplication+MPAdditions.h"

#import <AppKit/AppKit.h>

NSString *const MPWindowIDKey = @"MPWindowIDKey";
NSString *const MPWindowTitleKey = @"MPWindowTitleKey";
NSString *const MPProcessIdentifierKey = @"MPProcessIdentifierKey";

BOOL skipWindowTitle(NSString *windowTitle) {
  if(windowTitle.length <= 0) {
    return YES;
  }
  
  static NSSet *titlesToSkip;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    titlesToSkip = [NSSet setWithArray:@[@"Item-0", @"Focus Proxy"]];
  });
  
  return [titlesToSkip containsObject:windowTitle];
}

@implementation NSRunningApplication (MPAdditions)

- (NSDictionary *)mp_infoDictionary {
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  NSArray *windowNumbers = [NSWindow windowNumbersWithOptions:NSWindowNumberListAllApplications];
  NSUInteger minZIndex = NSNotFound;
  NSDictionary *infoDict = @{};
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowTitle = windowDict[(NSString *)kCGWindowName];
    /* skip a list of well know useless window-titles */
    if(skipWindowTitle(windowTitle)) {
      continue;
    }
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(self.processIdentifier)]) {
      
      NSNumber *windowId = (NSNumber *)windowDict[(NSString *)kCGWindowNumber];
      NSUInteger zIndex = [windowNumbers indexOfObject:windowId];
      if(zIndex < minZIndex) {
        minZIndex = zIndex;
        infoDict = @{
          MPWindowIDKey: windowId,
          MPWindowTitleKey: windowTitle,
          MPProcessIdentifierKey : processId
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

@end
