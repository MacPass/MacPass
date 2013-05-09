//
//  MPViewController.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPViewController : NSViewController

- (void)didLoadView;
- (NSResponder *)reconmendedFirstResponder;
/* Returns the associated window controller */
- (id)windowController;

- (void)updateResponderChain;

@end
