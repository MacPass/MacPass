//
//  MPViewController.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPModelChangeObserving.h"

@interface MPViewController : NSViewController

@property (nonatomic, readonly, nullable) NSWindowController *windowController;
@property (weak, nullable) id<MPModelChangeObserving> observer;
@property (nonatomic, readonly, nullable) NSResponder *reconmendedFirstResponder;

@end
