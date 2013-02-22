//
//  MPGeneralSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPSettingsTabProtocoll.h"
#import "MPViewController.h"

@interface MPGeneralSettingsController : MPViewController <MPSettingsTabProtocoll>
@property (assign) IBOutlet NSProgressIndicator *spinner;

@end
