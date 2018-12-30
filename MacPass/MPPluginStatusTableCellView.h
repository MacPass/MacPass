//
//  MPPluginStatusTableCellView.h
//  MacPass
//
//  Created by Michael Starke on 30.12.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPPluginStatusTableCellView : NSTableCellView

@property (strong) IBOutlet NSButton *actionButton;

@end

NS_ASSUME_NONNULL_END
