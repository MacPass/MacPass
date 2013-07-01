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


@property (assign) IBOutlet NSTabView *sectionTabView;

/* General Tab */
@property (assign) IBOutlet NSTextField *databaseNameTextField;
@property (assign) IBOutlet NSTextView *databaseDescriptionTextView;

/* Protection */
@property (assign) IBOutlet NSTextField *passwordTextField;
@property (assign) IBOutlet NSPathControl *keyfilePathControl;

/* Display Tab */
@property (assign) IBOutlet NSButton *protectTitleCheckButton;
@property (assign) IBOutlet NSButton *protectUserNameCheckButton;
@property (assign) IBOutlet NSButton *protectPasswortCheckButton;
@property (assign) IBOutlet NSButton *protectURLCheckButton;
@property (assign) IBOutlet NSButton *protectNotesCheckButton;


/* Advanced Tab*/
@property (assign) IBOutlet NSButton *enableRecycleBinCheckButton;
@property (assign) IBOutlet NSButton *emptyRecycleBinOnQuitCheckButton;
@property (assign) IBOutlet NSPopUpButton *selectRecycleBinGroupPopUpButton;

- (id)initWithDocument:(MPDocument *)document;
- (void)update;

@end
