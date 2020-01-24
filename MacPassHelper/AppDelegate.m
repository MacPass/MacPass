//
//  AppDelegate.m
//  MacPassHelper
//
//  Created by georgesnow on 1/22/20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
  pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
  NSString *path = [NSString pathWithComponents:pathComponents];
  NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
  NSLog(@"apps list: %@", apps);
  NSLog(@"bundleId: %@", [NSBundle mainBundle].bundleIdentifier);
  if([apps containsObject:[NSBundle mainBundle].bundleIdentifier]) {
  	[NSApp terminate:nil];
  }
  else {
    [[NSWorkspace sharedWorkspace] launchApplication:path];
    [NSApp terminate:nil];
  }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}


@end
