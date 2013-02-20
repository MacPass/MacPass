//
//  MPEntryViewController.h
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class KdbGroup;
@class MPOutlineViewDelegate;

@interface MPEntryViewController : MPViewController

@property (nonatomic, assign) id<NSOutlineViewDelegate> outlineViewDelegate;
@property (assign) KdbGroup *activeGroup;
@property (readonly, retain) NSArrayController *entryArrayController;
@property (nonatomic, retain) NSString *filter;

@end
