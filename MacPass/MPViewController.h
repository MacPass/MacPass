//
//  MPViewController.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPViewController : NSViewController

@property (nonatomic, readonly) NSWindowController *windowController;

- (void)didLoadView;
- (NSResponder *)reconmendedFirstResponder;
/* Returns the associated window controller */


- (void)updateResponderChain;

@end
