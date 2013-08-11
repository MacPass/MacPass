//
//  MPPasswordEditWindowController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPSheetWindowController.h"
@class MPDocument;
@class HNHRoundedSecureTextField;

@interface MPPasswordEditWindowController : MPSheetWindowController <NSTextFieldDelegate>

@property (weak) IBOutlet HNHRoundedSecureTextField *passwordTextField;
@property (weak) IBOutlet HNHRoundedSecureTextField *passwordRepeatTextField;
@property (weak) IBOutlet NSPathControl *keyfilePathControl;
@property (weak) IBOutlet NSButton *togglePasswordButton;
@property (weak) IBOutlet NSTextField *errorTextField;
@property (weak) IBOutlet NSButton *changePasswordButton;

/**
 *	Dedicated initializer for the Windowcontroller
 *	@param	document	The Database document that is currently active
 *	@return	initalized windowcontroller
 */
- (id)initWithDocument:(MPDocument *)document;

- (IBAction)clearKey:(id)sender;
- (IBAction)generateKey:(id)sender;


@end
