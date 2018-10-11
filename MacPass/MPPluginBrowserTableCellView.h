//
//  MPPluginBrowserTableCellView.h
//  MacPass
//
//  Created by Michael Starke on 11.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPPluginBrowserTableCellView : NSTableCellView

@property (strong) IBOutlet NSTextField *statusTextField;

@end

NS_ASSUME_NONNULL_END
