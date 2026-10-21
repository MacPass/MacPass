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
NSString *const MPWindowURLKey = @"MPWindowURLKey";
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

static id copyAccessibilityValue(AXUIElementRef element, CFStringRef attribute) {
  CFTypeRef value = NULL;
  AXError error = AXUIElementCopyAttributeValue(element, attribute, &value);
  id result = CFBridgingRelease(value);
  return error == kAXErrorSuccess ? result : nil;
}

/* Title and document URL of the focused window, keyed by MPWindowTitleKey and MPWindowURLKey */
static NSDictionary *focusedAccessibilityWindowInfo(pid_t pid) {
  if(!AXIsProcessTrusted()) {
    return nil;
  }

  AXUIElementRef application = AXUIElementCreateApplication(pid);
  // An unresponsive target must not stall the global shortcut indefinitely.
  AXUIElementSetMessagingTimeout(application, 0.5);
  id window = copyAccessibilityValue(application, kAXFocusedWindowAttribute);
  CFRelease(application);
  if(!window || CFGetTypeID((__bridge CFTypeRef)window) != AXUIElementGetTypeID()) {
    return nil;
  }

  AXUIElementRef windowElement = (__bridge AXUIElementRef)window;
  AXUIElementSetMessagingTimeout(windowElement, 0.5);
  NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
  id title = copyAccessibilityValue(windowElement, kAXTitleAttribute);
  if([title isKindOfClass:NSString.class]) {
    info[MPWindowTitleKey] = title;
  }
  /* Chrome publishes the URL of the active tab as the window's document. A document without
   a host, like the file of a text editor window, is of no use for matching. */
  id document = copyAccessibilityValue(windowElement, kAXDocumentAttribute);
  NSURL *url = [document isKindOfClass:NSURL.class] ? document : nil;
  if([document isKindOfClass:NSString.class]) {
    url = [NSURL URLWithString:document];
  }
  if(url.host.length > 0) {
    info[MPWindowURLKey] = url.absoluteString;
  }
  return info;
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
    // Chrome hands an ellipsized copy of long titles to the window server, which can
    // cut out the hostname used for Auto-Type matching. Accessibility exposes the full
    // focused window title and the URL of the page it shows.
    // Keep the CG window ID for the candidate preview and fall back to its title
    // when the target does not expose a usable Accessibility title.
    NSDictionary *accessibilityInfo = focusedAccessibilityWindowInfo(self.processIdentifier);
    NSMutableDictionary *fullInfo = [infoDict mutableCopy];
    NSString *title = accessibilityInfo[MPWindowTitleKey];
    if(!skipWindowTitle(title)) {
      fullInfo[MPWindowTitleKey] = title;
    }
    fullInfo[MPWindowURLKey] = accessibilityInfo[MPWindowURLKey];
    infoDict = fullInfo;
  }
  if(currentWindows.count > 0 && infoDict.count == 0) {
    // show some information about not being able to determine any windows
    NSLog(@"Unable to retrieve any window names. If you encounter this issue you might be running 10.15 and MacPass has no permission for screen recording.");
  }
  return infoDict;
}

@end
