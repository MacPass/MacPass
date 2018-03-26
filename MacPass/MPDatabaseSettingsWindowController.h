//
//  MPDocumentSettingsWindowController.h
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
@property (weak) IBOutlet NSTextField *fileVersionTextField;

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
@property (weak) IBOutlet NSStepper *argon2MemoryStepper;

/* Advanced Tab*/
@property (weak) IBOutlet NSButton *enableHistoryCheckButton;
@property (weak) IBOutlet NSTextField *historyMaximumItemsTextField;
@property (weak) IBOutlet NSStepper *historyMaximumItemsStepper;

@property (weak) IBOutlet NSTextField *historyMaximumSizeTextField;
@property (weak) IBOutlet NSStepper *historyMaximumSizeStepper;

@property (weak) IBOutlet NSButton *enableTrashCheckButton;
@property (weak) IBOutlet NSButton *emptyTrashOnQuitCheckButton;
@property (weak) IBOutlet NSPopUpButton *selectTrashGoupPopUpButton;
@property (weak) IBOutlet NSTextField *defaultUsernameTextField;
@property (weak) IBOutlet NSPopUpButton *templateGroupPopUpButton;

@property (weak) IBOutlet NSButton *recommendKeyChangeCheckButton;
@property (weak) IBOutlet NSButton *enforceKeyChangeCheckButton;
@property (weak) IBOutlet NSButton *enforceKeyChangeOnceCheckButton;
@property (weak) IBOutlet NSTextField *recommendKeyChangeIntervalTextField;
@property (weak) IBOutlet NSStepper *recommendKeyChangeIntervalStepper;
@property (weak) IBOutlet NSTextField *enforceKeyChangeIntervalTextField;
@property (weak) IBOutlet NSStepper *enforceKeyChangeIntervalStepper;

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab;

@end


