//
//  NSRunningApplication+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 15.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "NSRunningApplication+MPAdditions.h"

#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

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

static NSString *focusedAccessibilityWindowTitle(pid_t pid) {
  if(!AXIsProcessTrusted()) {
    return nil;
  }

  AXUIElementRef application = AXUIElementCreateApplication(pid);
  // An unresponsive target must not stall the global shortcut indefinitely.
  AXUIElementSetMessagingTimeout(application, 0.5);
  CFTypeRef window = NULL;
  AXError error = AXUIElementCopyAttributeValue(application, kAXFocusedWindowAttribute, &window);
  CFRelease(application);
  if(error != kAXErrorSuccess || !window) {
    if(window) {
      CFRelease(window);
    }
    return nil;
  }
  if(CFGetTypeID(window) != AXUIElementGetTypeID()) {
    CFRelease(window);
    return nil;
  }

  AXUIElementSetMessagingTimeout((AXUIElementRef)window, 0.5);
  CFTypeRef title = NULL;
  error = AXUIElementCopyAttributeValue((AXUIElementRef)window, kAXTitleAttribute, &title);
  CFRelease(window);
  id value = CFBridgingRelease(title);
  return error == kAXErrorSuccess && [value isKindOfClass:NSString.class] ? value : nil;
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
  if(infoDict.count > 0) {
    // WindowServer can ellipsize Chrome titles, including the hostname used for
    // Auto-Type matching. Accessibility exposes the full focused window title.
    // Keep the CG window ID for the candidate preview and fall back to its title
    // when the target does not expose a usable Accessibility title.
    NSString *title = focusedAccessibilityWindowTitle(self.processIdentifier);
    if(!skipWindowTitle(title)) {
      NSMutableDictionary *fullInfo = [infoDict mutableCopy];
      fullInfo[MPWindowTitleKey] = title;
      infoDict = fullInfo;
    }
  }
  if(currentWindows.count > 0 && infoDict.count == 0) {
    // show some information about not being able to determine any windows
    NSLog(@"Unable to retrieve any window names. If you encounter this issue you might be running 10.15 and MacPass has no permission for screen recording.");
  }
  return infoDict;
}

@end
