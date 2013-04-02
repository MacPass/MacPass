//
//  MPGeneralSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPGeneralSettingsController.h"
#import "MPSettingsHelper.h"

NSString *const MPGeneralSetingsIdentifier = @"GeneralSettingsTab";

@interface MPGeneralSettingsController ()

- (void)didLoadView;

@end

@implementation MPGeneralSettingsController

+ (NSString *)identifier {
  return MPGeneralSetingsIdentifier;
}

- (id)init {
  return [self initWithNibName:@"GeneralSettings" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)label {
  return NSLocalizedString(@"GENERAL_SETTINGS", @"General Settings Label");
}

- (void)didLoadView {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *clearPasteboardKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyClearPasteboardOnQuit];
  NSString *clearPasteboardTimeOutKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyPasteboardClearTimeout];
  [self.clearPasteboardOnQuitCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:clearPasteboardKeyPath options:nil];
  [self.clearPasteboardTimeoutPopup bind:NSSelectedTagBinding toObject:defaultsController withKeyPath:clearPasteboardTimeOutKeyPath options:nil];
  
}
@end
