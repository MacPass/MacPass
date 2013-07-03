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


@property (weak) IBOutlet NSTabView *sectionTabView;

/* General Tab */
@property (weak) IBOutlet NSTextField *databaseNameTextField;
@property (unsafe_unretained) IBOutlet NSTextView *databaseDescriptionTextView;

/* Protection */
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSPathControl *keyfilePathControl;

/* Display Tab */
@property (weak) IBOutlet NSButton *protectTitleCheckButton;
@property (weak) IBOutlet NSButton *protectUserNameCheckButton;
@property (weak) IBOutlet NSButton *protectPasswortCheckButton;
@property (weak) IBOutlet NSButton *protectURLCheckButton;
@property (weak) IBOutlet NSButton *protectNotesCheckButton;


/* Advanced Tab*/
@property (weak) IBOutlet NSButton *enableRecycleBinCheckButton;
@property (weak) IBOutlet NSButton *emptyRecycleBinOnQuitCheckButton;
@property (weak) IBOutlet NSPopUpButton *selectRecycleBinGroupPopUpButton;

- (id)initWithDocument:(MPDocument *)document;
- (void)update;

@end
