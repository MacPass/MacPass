//
//  MPOutlineViewController.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class MPOutlineViewDelegate;
@class KdbGroup;

@interface MPOutlineViewController : MPViewController

@property (retain, readonly) MPOutlineViewDelegate *outlineDelegate;
@property (assign, nonatomic) BOOL isVisible;


- (void)clearSelection;
- (void)showOutline;


- (void)createGroup:(id)sender;
- (void)createEntry:(id)sender;
- (void)deleteEntry:(id)sender;

@end
