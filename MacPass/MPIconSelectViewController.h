//
//  MPIconSelectViewController.h
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class MPDocument;

@interface MPIconSelectViewController : MPViewController <NSCollectionViewDelegate>

@property (weak, nullable) NSPopover *popover;

@end
