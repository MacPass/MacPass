//
//  MPPickfieldViewController.h
//  MacPass
//
//  Created by Michael Starke on 28.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MPDocument;

@interface MPPickfieldViewController : NSViewController

@property (weak) MPDocument *document;
@property (copy, readonly) NSString *pickedValue;

- (IBAction)pickField:(id)sender;

@end
