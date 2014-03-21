//
//  MPServerSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPIntegrationSettingsController.h"
#import "MPSettingsHelper.h"
#import "MPIconHelper.h"

@interface MPIntegrationSettingsController ()

@end

@implementation MPIntegrationSettingsController

- (NSString *)identifier {
  return @"Integration";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameComputer];
}

- (NSString *)label {
  return NSLocalizedString(@"INTEGRATION_SETTINGS", "");
}

- (id)init {
  self = [super initWithNibName:@"IntegrationSettings" bundle:nil];
  return self;
}

- (void)didLoadView {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *serverKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableHttpServer];
  NSString *globalAutotypeKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableGlobalAutotype];
  NSString *quicklookKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableQuicklookPreview];
  [self.enableServerCheckbutton bind:NSValueBinding toObject:defaultsController withKeyPath:serverKeyPath options:nil];
  [self.enableServerCheckbutton setEnabled:NO];
  [self.enableGlobalAutotypeCheckbutton bind:NSValueBinding toObject:defaultsController withKeyPath:globalAutotypeKeyPath options:nil];
  //[self.enableGlobalAutotypeCheckbutton setEnabled:NO];
  [self.enableQuicklookCheckbutton bind:NSValueBinding toObject:defaultsController withKeyPath:quicklookKeyPath options:nil];
}

@end
