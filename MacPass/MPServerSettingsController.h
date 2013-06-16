//
//  MPServerSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPSettingsTab.h"

@interface MPServerSettingsController : MPViewController <MPSettingsTab>

@property (assign) IBOutlet NSButton *enableServerCheckbutton;

@end
