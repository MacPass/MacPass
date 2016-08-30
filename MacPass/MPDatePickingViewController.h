//
//  MPDatePickingViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//


#import "MPViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MPDocument;

@interface MPDatePickingViewController : MPViewController

@property (nullable, weak) MPDocument *document;

@end

NS_ASSUME_NONNULL_END