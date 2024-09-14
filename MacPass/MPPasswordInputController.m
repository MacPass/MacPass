//
//  MPPasswordInputController.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
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

#import "MPPasswordInputController.h"
#import "MPAppDelegate.h"
#import "MPDocumentWindowController.h"
#import "MPDocument.h"
#import "MPDocument+BiometricEncryptionSupport.h"
#import "MPSettingsHelper.h"
#import "MPPathControl.h"
#import "MPTouchBarButtonCreator.h"
#import "MPSettingsHelper.h"
#import "MPConstants.h"
#import "MPTouchIdCompositeKeyStore.h"

#import "HNHUi/HNHUi.h"

#import "NSError+Messages.h"

@interface MPPasswordInputController ()

@property (strong) NSButton *showPasswordButton;
@property (weak) IBOutlet HNHUISecureTextField *passwordTextField;
@property (weak) IBOutlet MPPathControl *keyPathControl;
@property (weak) IBOutlet NSImageView *messageImageView;
@property (weak) IBOutlet NSTextField *messageInfoTextField;
@property (strong) IBOutlet NSTextField *keyFileWarningTextField;
@property (weak) IBOutlet NSButton *togglePasswordButton;
@property (weak) IBOutlet NSButton *enablePasswordCheckBox;
@property (weak) IBOutlet NSButton *unlockButton;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *touchIdButton;
@property (weak) IBOutlet NSButton *touchIdEnabledButton;
@property (strong) IBOutlet NSPopUpButton *touchIdModeButton;

@property (copy) NSString *message;
@property (copy) NSString *cancelLabel;

@property (assign) BOOL showPassword;
@property (nonatomic, assign) BOOL enablePassword;
@property (copy) passwordInputCompletionBlock completionHandler;

@end

@implementation MPPasswordInputController

- (NSString *)nibName {
  return @"PasswordInputView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _enablePassword = YES;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_selectKeyURL) name:MPDidChangeStoredKeyFilesSettings object:nil];
  }
  return self;
}

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didSetKeyURL:) name:MPPathControlDidSetURLNotification object:self.keyPathControl];
  self.messageImageView.image = [NSImage imageNamed:NSImageNameCaution];
  [self.passwordTextField bind:NSStringFromSelector(@selector(showPassword)) toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.enablePasswordCheckBox bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enablePassword)) options:nil];
  [self.togglePasswordButton bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enablePassword)) options:nil];
  [self.passwordTextField bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enablePassword)) options:nil];
  
  NSMenu* touchIDMenu = [[NSMenu alloc] init];
  NSMenuItem *disabledItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"TOUCHID_DISABLED", @"menu item to disable touchid key storage")
                             action:NULL
                      keyEquivalent:@""];
  NSMenuItem *transitentItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"TOUCHID_TRANSIENT_KEY_STORAGE", @"menu item to enable transient touchid key storage")
                             action:NULL
                      keyEquivalent:@""];
  NSMenuItem *persistentItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"TOUCHID_PERSISTENT_KEY_STORAGE", @"menu item to enable persisntent touchid key storage")
                             action:NULL
                      keyEquivalent:@""];
  
  disabledItem.tag = MPTouchIDKeyStorageDisabled;
  transitentItem.tag = MPTouchIDKeyStorageTransient;
  persistentItem.tag = MPTouchIDKeyStoragePersistent;
  
  touchIDMenu.itemArray = @[disabledItem, transitentItem, persistentItem];
  self.touchIdModeButton.menu = touchIDMenu;
  [self.touchIdModeButton bind:NSSelectedTagBinding
                         toObject:NSUserDefaultsController.sharedUserDefaultsController
                      withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyTouchIdEnabled]
                          options:nil];
  [self.touchIdEnabledButton bind:NSValueBinding
                         toObject:NSUserDefaultsController.sharedUserDefaultsController
                      withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyTouchIdEnabled]
                          options:nil];
  self.touchIdEnabledButton.hidden = YES;
  if (@available(macOS 10.13.4, *)) {
    self.touchIdEnabledButton.hidden = NO;
    [self _touchIdUpdateToolTip];
  }
  [self _reset];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (void)requestPasswordWithMessage:(NSString *)message cancelLabel:(NSString *)cancelLabel completionHandler:(passwordInputCompletionBlock)completionHandler {
  self.completionHandler = completionHandler;
  self.message = message;
  self.cancelLabel = cancelLabel;
  [self _reset];
}

#pragma mark Properties
- (void)setEnablePassword:(BOOL)enablePassword {
  if(_enablePassword != enablePassword) {
    _enablePassword = enablePassword;
    if(!_enablePassword) {
      self.passwordTextField.stringValue = @"";
    }
  }
  if(_enablePassword) {
    self.passwordTextField.placeholderString = NSLocalizedString(@"PASSWORD_INPUT_ENTER_PASSWORD", "Placeholder in the unlock-password input field if password is enabled");
  }
  else {
    self.passwordTextField.placeholderString = NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "Placeholder in the unlock-password input field if password is disabled");
  }
}

#pragma mark -
#pragma mark Private
- (IBAction)_submit:(id)sender {
  if(!self.completionHandler) {
    return;
  }
  
  /* No password is different than an empty password */
  NSError *error = nil;
  NSString *password = self.enablePassword ? self.passwordTextField.stringValue : nil;
  
  BOOL cancel = (sender == self.cancelButton);
  NSURL* keyURL = self.keyPathControl.URL;
  NSData *keyFileData = keyURL ? [NSData dataWithContentsOfURL:keyURL] : nil;
  KPKKey* passwordKey = [KPKKey keyWithPassword:password];
  KPKKey* fileKey = [KPKKey keyWithKeyFileData:keyFileData];
  KPKCompositeKey* compositeKey = [[KPKCompositeKey alloc] init];
  [compositeKey addKey:passwordKey];
  [compositeKey addKey:fileKey];
  /* After the completion handler finished we no longer have a windowController set */
  NSString* documentKey = [self biometricKeyForCurrentDocument];
  BOOL result = self.completionHandler(compositeKey, keyURL, cancel, &error);
  if(result) {
    if(nil != documentKey) {
      [MPTouchIdCompositeKeyStore.defaultStore saveCompositeKey:compositeKey forDocumentKey:documentKey];
    }
    return;
  }
  if(cancel) {
    return;
  }
  [self _showError:error];
  /* do not shake if we are a sheet */
  if(!self.view.window.isSheet) {
    [self.view.window shakeWindow:nil];
  }
}
/*
- (KPKCompositeKey*)_touchIdDecryptCompositeKey:(NSData*)encryptedKey {
  NSError *error;
  return [MPTouchIdCompositeKeyStore.defaultStore compositeKeyForEncryptedKeyData:encryptedKey error:&error];
}*/

- (NSString *)biometricKeyForCurrentDocument {
  MPDocument* currentDocument = (MPDocument *)self.windowController.document;
  return currentDocument.biometricKey;
}

- (bool) _touchIdIsUnlockAvailable {
  MPDocument *currentDocument = (MPDocument *)self.windowController.document;
  return (nil != currentDocument.encryptedKeyData);
}

- (IBAction)unlockWithTouchID:(id)sender {
  NSString* documentKey = [self biometricKeyForCurrentDocument];
  if(nil == documentKey) {
    return;
  }
  NSData* encryptedKey = [MPTouchIdCompositeKeyStore.defaultStore loadEncryptedCompositeKeyForDocumentKey:documentKey];
  if(!encryptedKey) {
    self.touchIdButton.enabled = NO;
    return;
  }
  NSError *error;
  KPKCompositeKey* compositeKey = [MPTouchIdCompositeKeyStore.defaultStore compositeKeyForEncryptedKeyData:encryptedKey error:&error];
  if(!compositeKey) {
    self.touchIdButton.enabled = NO;
    return;
  }
  bool success = self.completionHandler(compositeKey, NULL, false, &error);
  if(success) {
    return;
  }
  // TODO: clear encryptedKey if password was wrong? Show user feedback? 
  self.touchIdButton.enabled = NO;
  [self _showError:error];
}

- (IBAction)touchIdEnabledChanged:(id)sender {
  [self _touchIdUpdateToolTip];
}

- (void) _touchIdUpdateToolTip {
  switch(self.touchIdEnabledButton.state) {
    case NSControlStateValueOn:
      self.touchIdEnabledButton.toolTip = NSLocalizedString(@"TOOLTIP_TOUCHID_ENABELD", @"Tooltip displayed when TouchID is is fully enabeld");
    case NSControlStateValueOff:
      self.touchIdEnabledButton.toolTip = NSLocalizedString(@"TOOLTIP_TOUCHID_DISABLED", @"Tooltip displayed when TouchID is disabled");
    case NSControlStateValueMixed:
    default:
      self.touchIdEnabledButton.toolTip = NSLocalizedString(@"TOOLTIP_TOUCHID_TRANSIENT", @"Tooltip displayed when TouchID is in transient (inmemory) mode");
  }
}

- (IBAction)resetKeyFile:(id)sender {
  /* If the reset was triggered by ourselves we want to preselect the keyfile */
  if(sender == self) {
    [self _selectKeyURL];
  }
  else {
    self.keyPathControl.URL = nil;
  }
}

- (void)_reset {
  self.showPassword = NO;
  self.enablePassword = YES;
  self.passwordTextField.stringValue = @"";
  self.messageInfoTextField.hidden = (nil == self.message);
  self.touchIdButton.hidden = ![self _touchIdIsUnlockAvailable];
  self.touchIdButton.enabled = YES;

  if(self.message) {
    self.messageInfoTextField.stringValue = self.message;
    self.messageImageView.image = [NSImage imageNamed:NSImageNameInfo];
  }
  else {
    self.messageImageView.image = [NSImage imageNamed:NSImageNameCaution];
  }
  self.messageImageView.hidden = (nil == self.message);
  self.cancelButton.hidden = (nil == self.cancelLabel);
  if(self.cancelLabel) {
    self.cancelButton.stringValue = self.cancelLabel;
  }
  [self resetKeyFile:self];
}

- (void)_selectKeyURL {
  MPDocument *document = self.windowController.document;
  self.keyPathControl.URL = document.suggestedKeyURL;
}

- (void)_showError:(NSError *)error {
  if(error) {
    self.messageInfoTextField.stringValue = error.descriptionForErrorCode;
  }
  self.messageImageView.hidden = NO;
  self.messageImageView.image = [NSImage imageNamed:NSImageNameCaution];
  self.messageInfoTextField.hidden = NO;
}


- (NSTouchBar *)makeTouchBar {
  NSTouchBar *touchBar = [[NSTouchBar alloc] init];
  touchBar.delegate = self;
  touchBar.customizationIdentifier = MPTouchBarCustomizationIdentifierPasswordInput;
  NSArray<NSTouchBarItemIdentifier> *defaultItemIdentifiers = @[MPTouchBarItemIdentifierShowPassword, MPTouchBarItemIdentifierChooseKeyfile, NSTouchBarItemIdentifierFlexibleSpace,MPTouchBarItemIdentifierUnlock];
  touchBar.defaultItemIdentifiers = defaultItemIdentifiers;
  touchBar.customizationAllowedItemIdentifiers = defaultItemIdentifiers;
  return touchBar;
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier  API_AVAILABLE(macos(10.12.2)) {
  if (identifier == MPTouchBarItemIdentifierChooseKeyfile) {
    return [MPTouchBarButtonCreator touchBarButtonWithTitleAndImage:NSLocalizedString(@"TOUCHBAR_CHOOSE_KEYFILE","Touchbar button label for choosing the keyfile") identifier:MPTouchBarItemIdentifierChooseKeyfile image:[NSImage imageNamed:NSImageNameTouchBarFolderTemplate] target:self.keyPathControl selector:@selector(showOpenPanel:) customizationLabel:NSLocalizedString(@"TOUCHBAR_CHOOSE_KEYFILE","Touchbar button label for choosing the keyfile")];
  } else if (identifier == MPTouchBarItemIdentifierShowPassword) {
    NSTouchBarItem *item = [MPTouchBarButtonCreator touchBarButtonWithTitleAndImage:NSLocalizedString(@"TOUCHBAR_SHOW_PASSWORD","Touchbar button label for showing the password") identifier:MPTouchBarItemIdentifierShowPassword image:[NSImage imageNamed:NSImageNameTouchBarQuickLookTemplate] target:self selector:@selector(toggleShowPassword) customizationLabel:NSLocalizedString(@"TOUCHBAR_SHOW_PASSWORD","Touchbar button label for showing the password")];
    _showPasswordButton = (NSButton *) item.view;
    return item;
  } else if (identifier == MPTouchBarItemIdentifierUnlock) {
    return [MPTouchBarButtonCreator touchBarButtonWithImage:[NSImage imageNamed:NSImageNameLockUnlockedTemplate] identifier:MPTouchBarItemIdentifierUnlock target:self selector:@selector(_submit:) customizationLabel:NSLocalizedString(@"TOUCHBAR_UNLOCK_DATABASE","Touchbar button label for unlocking the database")];
  } else {
    return nil;
  }
}

- (void)toggleShowPassword {
  self.showPassword = !self.showPassword;
  self.showPasswordButton.bezelColor = self.showPassword ? [NSColor selectedControlColor] : [NSColor controlColor];
}

- (void)_didSetKeyURL:(NSNotification *)notification {
  if(notification.object != self.keyPathControl) {
    return; // wrong sender
  }
  NSDocument *document = (NSDocument *)self.windowController.document;
  NSData *keyFileData = [NSData dataWithContentsOfURL:self.keyPathControl.URL];
  KPKFileVersion keyFileVersion = [KPKFormat.sharedFormat fileVersionForData:keyFileData];
  BOOL isKdbDatabaseFile = (keyFileVersion.format != KPKDatabaseFormatUnknown);
  if(isKdbDatabaseFile) {
    if([document.fileURL isEqual:self.keyPathControl.URL]) {
      self.keyFileWarningTextField.stringValue = NSLocalizedString(@"WARNING_CURRENT_DATABASE_FILE_SELECTED_AS_KEY_FILE", "Error message displayed when the current database file is also set as the key file");
      self.keyFileWarningTextField.hidden = NO;
    }
    else {
      self.keyFileWarningTextField.stringValue = NSLocalizedString(@"WARNING_DATABASE_FILE_SELECTED_AS_KEY_FILE", "Error message displayed when a keepass database file is set as the key file");
      self.keyFileWarningTextField.hidden = NO;
    }
  }
  else {
    self.keyFileWarningTextField.stringValue = @"";
    self.keyFileWarningTextField.hidden = YES;
  }
}

@end
