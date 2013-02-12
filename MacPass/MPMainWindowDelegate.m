//
//  MPMainWindowDelegate.m
//  MacPass
//
//  Created by michael starke on 12.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPMainWindowDelegate.h"

@implementation MPMainWindowDelegate

- (void)newDocument:(id)sender {
  NSLog(@"New");
}

- (void)performClose:(id)sender {
  NSLog(@"Close");
}

- (void)openDocument:(id)sender {
  NSLog(@"New Document");
}

@end
