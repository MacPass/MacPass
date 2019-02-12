//
//  MPPluginRepositoryBrowserViewController.h
//  MacPass
//
//  Created by Michael Starke on 11.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPPluginRepositoryBrowserViewController : NSViewController

- (IBAction)refresh:(id)sender;
- (IBAction)executePluginAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
