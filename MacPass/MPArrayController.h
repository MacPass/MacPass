//
//  MPArrayController.h
//  MacPass
//
//  Created by Michael Starke on 30/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MPModelChangeObserving;

@interface MPArrayController : NSArrayController

@property (weak) id<MPModelChangeObserving> observer;

@end
