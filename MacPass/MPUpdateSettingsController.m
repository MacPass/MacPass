//
//  MPUpdateSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 04.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPUpdateSettingsController.h"

@interface MPUpdateSettingsController ()

@end

@implementation MPUpdateSettingsController

- (instancetype)init {
  self = [super initWithNibName:@"UpdateSettings" bundle:nil];
  return self;
}

- (NSString *)identifier {
  return @"UpdateSettings";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameApplicationIcon];
}

- (NSString *)label {
  return NSLocalizedString(@"UPDATE_SETTINGS", @"Update Settings Label");
}

@end
