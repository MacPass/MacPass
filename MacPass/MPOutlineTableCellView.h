//
//  MPOutlineTableCellView.h
//  MacPass
//
//  Created by Michael Starke on 26.09.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPOutlineTableCellView : NSTableCellView

@property (nonatomic) NSInteger count;
@property (nonatomic) BOOL hideZeroCount;
@property (nonatomic, strong) IBOutlet NSButton *countButton;

@end

NS_ASSUME_NONNULL_END
