//
//  MPAutotypePickchars.m
//  MacPass
//
//  Created by Michael Starke on 23.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypePickchars.h"
#import "MPPickcharViewController.h"

@implementation MPAutotypePickchars

- (void)execute {
  dispatch_sync(dispatch_get_main_queue(), ^{
    
    
    MPPickcharViewController *vc = [[MPPickcharViewController alloc] init];
    vc.sourceValue = @"ThisIsANicePassword";
    vc.countToPick = 10;
    
    
    NSPanel *panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                                styleMask:NSWindowStyleMaskNonactivatingPanel|NSWindowStyleMaskTitled
                                                  backing:NSBackingStoreRetained
                                                    defer:YES];
    panel.level = NSScreenSaverWindowLevel;
    panel.contentViewController = vc;
    [panel center];
    [panel makeKeyAndOrderFront:self];
    
    if(NSModalResponseOK == [NSApp runModalForWindow:panel]) {
      // Do some stuff!
    }
  });
}

@end
