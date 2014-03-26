//
//  MPFixAutotypeWindowController.h
//  MacPass
//
//  Created by Michael Starke on 26/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPFixAutotypeWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

- (void)reset;

@end
