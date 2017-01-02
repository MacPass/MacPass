//
//  MPDocumentSettingsWindowController.h
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HNHUi/HNHUi.h>

typedef NS_ENUM(NSUInteger, MPDatabaseSettingsTab) {
  MPDatabaseSettingsTabGeneral,
  MPDatabaseSettingsTabSecurity,
  MPDatabaseSettingsTabAdvanced
};

@class MPDocument;
@class HNHRoundedTextField;

@interface MPDatabaseSettingsWindowController : HNHUISheetWindowController <NSTextFieldDelegate, NSTabViewDelegate>

@property (weak) IBOutlet NSTabView *sectionTabView;

/* General Tab */
@property (weak) IBOutlet NSTextField *databaseNameTextField;
@property (weak) IBOutlet NSPopUpButton *databaseCompressionPopupButton;
@property (unsafe_unretained) IBOutlet NSTextView *databaseDescriptionTextView;
@property (weak) IBOutlet NSColorWell *databaseColorColorWell;

/* Security Tab */
@property (weak) IBOutlet NSButton *createKeyDerivationParametersButton;
@property (weak) IBOutlet NSPopUpButton *cipherPopupButton;
@property (weak) IBOutlet NSPopUpButton *keyDerivationPopupButton;
@property (weak) IBOutlet NSTabView *keyDerivationSettingsTabView;

/* AES */
@property (weak) IBOutlet NSTextField *aesEncryptionRoundsTextField;
/* Argon2 */
@property (weak) IBOutlet NSTextField *argon2ThreadsTextField;
@property (weak) IBOutlet NSTextField *argon2IterationsTextField;
@property (weak) IBOutlet NSTextField *argon2MemoryTextField;

/* Advanced Tab*/
@property (weak) IBOutlet NSButton *enableHistoryCheckButton;
@property (weak) IBOutlet NSTextField *historyMaximumItemsTextField;
@property (weak) IBOutlet NSTextField *historyMaxiumSizeTextField;
@property (weak) IBOutlet NSButton *enableTrashCheckButton;
@property (weak) IBOutlet NSButton *emptyTrashOnQuitCheckButton;
@property (weak) IBOutlet NSPopUpButton *selectTrashGoupPopUpButton;
@property (weak) IBOutlet NSTextField *defaultUsernameTextField;
@property (weak) IBOutlet NSPopUpButton *templateGroupPopUpButton;

@property (weak) IBOutlet NSButton *recommendKeyChangeCheckButton;
@property (weak) IBOutlet NSButton *enforceKeyChangeCheckButton;
@property (weak) IBOutlet NSTextField *recommendKeyChangeIntervalTextField;
@property (weak) IBOutlet NSTextField *enforceKeyChangeIntervalTextField;

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab;

@end


