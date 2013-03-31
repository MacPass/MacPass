//
//  MPGeneralSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPAbstractSettingsViewController.h"

@interface MPGeneralSettingsController : MPAbstractSettingsViewController <MPSettingsTab>
@property (assign) IBOutlet NSImageView *imageView;

@end
