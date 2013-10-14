//
//  MPDocumentSettingsWindowController.h
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPSheetWindowController.h"

typedef NS_ENUM(NSUInteger, MPDatabaseSettingsTab) {
  MPDatabaseSettingsTabGeneral,
  MPDatabaseSettingsTabSecurity,
  MPDatabaseSettingsTabAdvanced
};

@class MPDocument;
@class HNHRoundedTextField;

@interface MPDatabaseSettingsWindowController : MPSheetWindowController <NSTextFieldDelegate, NSTabViewDelegate>

@property (weak) IBOutlet NSTabView *sectionTabView;

/* General Tab */
@property (weak) IBOutlet NSTextField *databaseNameTextField;
@property (weak) IBOutlet NSPopUpButton *databaseCompressionPopupButton;
@property (unsafe_unretained) IBOutlet NSTextView *databaseDescriptionTextView;
@property (weak) IBOutlet NSColorWell *databaseColorColorWell;

/* Security Tab */
@property (weak) IBOutlet NSButton *protectTitleCheckButton;
@property (weak) IBOutlet NSButton *protectUserNameCheckButton;
@property (weak) IBOutlet NSButton *protectPasswortCheckButton;
@property (weak) IBOutlet NSButton *protectURLCheckButton;
@property (weak) IBOutlet NSButton *protectNotesCheckButton;
@property (weak) IBOutlet NSTextField *encryptionRoundsTextField;
@property (weak) IBOutlet NSButton *benchmarkButton;

/* Advanced Tab*/
@property (weak) IBOutlet NSButton *enableRecycleBinCheckButton;
@property (weak) IBOutlet NSButton *emptyRecycleBinOnQuitCheckButton;
@property (weak) IBOutlet NSPopUpButton *selectRecycleBinGroupPopUpButton;
@property (weak) IBOutlet NSTextField *defaultUsernameTextField;
@property (weak) IBOutlet NSPopUpButton *templateGroupPopUpButton;


- (id)initWithDocument:(MPDocument *)document;

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab;

@end


