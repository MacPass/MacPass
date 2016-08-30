//
//  MPArrayController.h
//  MacPass
//
//  Created by Michael Starke on 30/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MPDocument;

@interface MPArrayController : NSArrayController

@property (weak) MPDocument *document;

@end
