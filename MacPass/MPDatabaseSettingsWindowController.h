//
//  MPDocumentSettingsWindowController.h
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPDatabaseSettingsDelegate.h"

typedef NS_ENUM(NSUInteger, MPDatabaseSettingsTab) {
  MPDatabaseSettingsTabGeneral,
  MPDatabaseSettingsTabPassword,
  MPDatabaseSettingsTabDisplay,
  MPDatabaseSettingsTabAdvanced,
  MPDatabaseSettingsTabTemplates,
};

@class MPDocument;
@class HNHRoundedTextField;
@class HNHRoundedSecureTextField;

@interface MPDatabaseSettingsWindowController : NSWindowController <NSTextFieldDelegate, NSTabViewDelegate>

@property (nonatomic,weak) id<MPDatabaseSettingsDelegate> delegate;

@property (weak) IBOutlet NSTabView *sectionTabView;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSButton *cancelButton;

/* General Tab */
@property (weak) IBOutlet NSTextField *databaseNameTextField;
@property (unsafe_unretained) IBOutlet NSTextView *databaseDescriptionTextView;

/* Protection */
@property (weak) IBOutlet HNHRoundedSecureTextField *passwordTextField;
@property (weak) IBOutlet HNHRoundedSecureTextField *passwordRepeatTextField;
@property (weak) IBOutlet NSPathControl *keyfilePathControl;
@property (weak) IBOutlet NSButton *togglePasswordButton;
@property (weak) IBOutlet NSTextField *errorTextField;


- (IBAction)clearKey:(id)sender;
- (IBAction)generateKey:(id)sender;

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


/* Templates Tab */
@property (weak) IBOutlet HNHRoundedTextField *defaultUsernameTextField;
@property (weak) IBOutlet NSPopUpButton *templateGroupPopUpButton;


- (id)initWithDocument:(MPDocument *)document;

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab;

- (void)update;


@end


