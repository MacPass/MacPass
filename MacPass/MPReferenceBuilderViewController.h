//
//  MPReferenceBuilderViewController.h
//  MacPass
//
//  Created by Michael Starke on 05/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@interface MPReferenceBuilderViewController : MPViewController
@property (weak) IBOutlet NSPopUpButton *valuePopUpButton;
@property (weak) IBOutlet NSPopUpButton *searchKeyPopUpButton;
@property (weak) IBOutlet NSTextField *searchStringTextField;
@property (weak) IBOutlet NSTextField *referenceStringTextField;

- (IBAction)updateReference:(id)sender;
- (IBAction)updateKey:(id)sender;

@end
