//
//  MPContextBarViewController.h
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@protocol MPContextBarDelegate <NSObject>

@optional
- (void)contextBarDidChangeFilter;
- (void)contextBarDidExitFilter;
- (void)contextBarDidExitHistory;
- (void)contextBarShouldEmptyTrash;
@end

typedef NS_OPTIONS(NSUInteger, MPFilterModeType) {
  MPFilterNone      = 0,
  MPFilterUrls      = (1<<0),
  MPFilterUsernames = (1<<1),
  MPFilterTitles    = (1<<2),
  MPFilterPasswords = (1<<3),
};

@class HNHGradientView;

@interface MPContextBarViewController : MPViewController

@property (nonatomic, assign) MPFilterModeType filterMode;
@property (nonatomic, readonly) BOOL hasFilter;
@property (nonatomic, weak) id<MPContextBarDelegate> delegate;
@property (weak) NSView *nextKeyView;

- (NSString *)filterString;
- (NSArray *)filterPredicates;

- (IBAction)toggleFilterSpace:(id)sender;

- (BOOL)showsFilter;
- (BOOL)showsHistory;
- (BOOL)showsTrash;

- (void)exitFilter;
- (void)showFilter;

- (void)showHistory;
- (void)showTrash;

- (void)enable;
- (void)disable;

@end
