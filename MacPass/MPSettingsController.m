//
//  MPSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPSettingsController.h"
#import "MPGeneralSettingsController.h"

NSString const* kMPPasswordEnvodingSettingsKey = @"PasswordEncoding";

@interface MPSettingsController ()
@property (retain) MPGeneralSettingsController *generalController;
@end

@implementation MPSettingsController
@synthesize generalController = _generalController;

-(id)init {
  self = [super initWithWindowNibName:@"SettingsWindow"];
  return self;
}

- (void)windowDidLoad {
  _generalController = [[MPGeneralSettingsController alloc] init];
  [_generalController loadView];
  [[self window] setContentView:[_generalController view]];
}

@end
