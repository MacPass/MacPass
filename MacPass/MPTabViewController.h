//
//  MPTabViewController.h
//  MacPass
//
//  Created by Michael Starke on 30.06.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPTabViewController : NSTabViewController

@property (nonatomic, copy, nullable) void (^willSelectTabHandler)(NSTabViewItem *item);
@property (nonatomic, copy, nullable) void (^didSelectTabHandler)(NSTabViewItem *item);

@end

NS_ASSUME_NONNULL_END
