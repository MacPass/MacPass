//
//  MPContextBarViewController.h
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPDocument+Search.h"

@protocol MPContextBarDelegate <NSObject>

@optional
- (void)contextBarDidChangeFilter;
- (void)contextBarDidExitFilter;
- (void)contextBarDidExitHistory;
- (void)contextBarShouldEmptyTrash;
@end

@class HNHGradientView;

@interface MPContextBarViewController : MPViewController

@property (nonatomic, readonly) BOOL hasFilter;
@property (nonatomic, weak) id<MPContextBarDelegate> delegate;
@property (weak) NSView *nextKeyView;

- (IBAction)toggleFilterSpace:(id)sender;
- (IBAction)exitFilter:(id)sender;

- (BOOL)showsFilter;
- (BOOL)showsHistory;
- (BOOL)showsTrash;

- (void)showFilter;

- (void)showHistory;
- (void)showTrash;

@end
