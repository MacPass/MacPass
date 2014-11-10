//
//  MPIconSelectViewController.h
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

FOUNDATION_EXTERN NSInteger const kMPDefaultIcon;

@interface MPIconSelectViewController : MPViewController <NSCollectionViewDelegate>

/**
 *  Is the selected Icon, kMPDefaultIcon if the default icons was selected
 */
@property (nonatomic, readonly, assign) NSInteger selectedIcon;
@property (nonatomic, readonly, assign) BOOL didCancel;

@property (weak) NSPopover *popover;

- (void)reset;
- (IBAction)cancel:(id)sender;
- (IBAction)useDefault:(id)sender;

@end
