//
//  MPToolbarItem.m
//  MacPass
//
//  Created by Michael Starke on 09.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPToolbarItem.h"
#import "MPActionHelper.h"

@implementation MPToolbarItem

- (void)validate {
  if(![self.view menu]) {
    id target = [NSApp targetForAction:[self action] to:nil from:self];
    id windowController = [[self.view window] windowController];
    BOOL isValid = (nil != target);
    if( [windowController respondsToSelector:@selector(validateToolbarItem:)]) {
      isValid &= [windowController validateToolbarItem:self];
    }
    [self setEnabled:isValid];
  }
}
@end
