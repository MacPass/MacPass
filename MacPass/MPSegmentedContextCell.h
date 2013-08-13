//
//  MPSegmentedContextCell.h
//  MacPass
//
//  Created by Michael Starke on 13.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPSegmentedContextCell : NSSegmentedCell

@property (nonatomic, assign) SEL contextMenuAction;
@property (nonatomic, weak) id contextMenuTarget;

@end
