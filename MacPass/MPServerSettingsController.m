//
//  MPServerSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPServerSettingsController.h"
#import "MPSettingsHelper.h"
#import "MPIconHelper.h"

@interface MPServerSettingsController ()

@end

@implementation MPServerSettingsController

- (NSString *)identifier {
  return @"ServerSettings";
}

- (NSImage *)image {
  return [MPIconHelper icon:MPIconServer];
}

- (NSString *)label {
  return NSLocalizedString(@"SERVER_SETTINGS", "");
}

- (id)init {
  self = [super initWithNibName:@"ServerSettings" bundle:nil];
  return self;
}

- (void)didLoadView {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *serverKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyEnableHttpServer];
  [self.enableServerCheckbutton bind:NSValueBinding toObject:defaultsController withKeyPath:serverKeyPath options:nil];
  [self.enableServerCheckbutton setEnabled:NO];
}

@end
