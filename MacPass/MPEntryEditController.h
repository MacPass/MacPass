//
//  MPEntryEditController.h
//  MacPass
//
//  Created by michael starke on 21.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
@class KdbNode;

@interface MPEntryEditController : MPViewController

@property (retain) id selectedItem;

- (IBAction)save:(id)sender;

@end
