//
//  NSUserNotification+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 05.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "NSUserNotification+MPAdditions.h"

@implementation NSUserNotification (MPAdditions)

- (BOOL)showsButtons {
  return [[self valueForKey:@"_showsButtons"] boolValue];
}

- (void)setShowsButtons:(BOOL)showsButtons {
  [self setValue:@(showsButtons) forKey:@"_showsButtons"];
}

@end
