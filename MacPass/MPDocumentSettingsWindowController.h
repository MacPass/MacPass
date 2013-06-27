//
//  MPDocumentSettingsWindowController.h
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MPDocument;

@interface MPDocumentSettingsWindowController : NSWindowController

/* General */
@property (assign) IBOutlet NSTextField *databaseNameTextField;
@property (assign) IBOutlet NSTextView *databaseDescriptionTextView;
/* Protection */
@property (assign) IBOutlet NSTextField *passwordTextField;
@property (assign) IBOutlet NSPathControl *keyfilePathControl;

/* Display */
@property (assign) IBOutlet NSButton *protectTitleCheckButton;
@property (assign) IBOutlet NSButton *protectUserNameCheckButton;
@property (assign) IBOutlet NSButton *protectPasswortCheckButton;
@property (assign) IBOutlet NSButton *protectURLCheckButton;
@property (assign) IBOutlet NSButton *protectNotesCheckButton;

- (id)initWithDocument:(MPDocument *)document;

- (IBAction)saveChanges:(id)sender;

@end
