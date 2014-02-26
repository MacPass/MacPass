//
//  MPContextBarViewController.h
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPDocument+Search.h"

@class HNHGradientView;
@class MPDocument;

@interface MPContextBarViewController : MPViewController

@property (weak) NSView *nextKeyView;

- (void)registerNotificationsForDocument:(MPDocument *)document;

- (IBAction)toggleFilterSpace:(id)sender;

- (BOOL)showsFilter;
- (BOOL)showsHistory;
- (BOOL)showsTrash;

- (void)showFilter;

- (void)showHistory;
- (void)showTrash;

@end
