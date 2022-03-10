//
//  AppDelegate.m
//  AutotypeOverlay
//
//  Created by Michael Starke on 09.03.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "AOAppDelegate.h"
#import <ApplicationServices/ApplicationServices.h>

@interface AOAppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end

@implementation AOAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  
  if(!AXIsProcessTrusted()) {
    NSString *name = [NSBundle.mainBundle.infoDictionary[@"CFBundleName"] copy];
    NSLog(@"%@ requires Accessibilty Permissions to work.", name);
  }
  
  [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(_didDeactivateApplication:) name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
  [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(_didActivateApplication:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
  return YES;
}

- (void)_didDeactivateApplication:(NSNotification *)notification {
  //[self.window orderOut:nil];
}

- (void)_didActivateApplication:(NSNotification *)notification {
  AXUIElementRef systemWide = AXUIElementCreateSystemWide();
  if(NULL == systemWide) {
    return;
  }
  CFTypeRef elementRef;
  AXError error = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute, &elementRef);
  if(error == kAXErrorSuccess) {
    [self _updateFocusedElement:elementRef];
  }
}

- (void)_updateFocusedElement:(AXUIElementRef)element {
  if(CFGetTypeID(element) != AXUIElementGetTypeID()) {
    return; // wrong type or NULL
  }
  CFTypeRef positionRef;
  AXError error = AXUIElementCopyAttributeValue(element, kAXPositionAttribute, &positionRef);
  if(error != kAXErrorSuccess || kAXValueTypeCGPoint != AXValueGetType(positionRef)) {
    return;
  }
  CGPoint position;
  AXValueGetValue(positionRef, kAXValueTypeCGPoint, &position);
  
  
  
  
  
  
  [self.window orderFront:self];
  [self.window setFrameTopLeftPoint:position];
  NSLog(@"Setting position to %@", NSStringFromPoint(position));
}

@end
