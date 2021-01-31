//
//  MPPasswordEditWindowController.m
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
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

#import "MPPasswordEditWindowController.h"
#import "MPDocument.h"
#import "MPPathControl.h"

#import "HNHUi/HNHUi.h"

#import "KeePassKit/KeePassKit.h"

typedef NS_ENUM(NSUInteger, MPPasswordEditPasswordError) {
  MPPasswordEditPasswordErrorNone,
  MPPasswordEditPasswordErrorNoPassword,
  MPPasswordEditPasswordErrorRepeatMissmatch
};

typedef NS_ENUM(NSUInteger, MPPasswordEditKeyError) {
  MPPasswordEditKeyErrorNone,
  MPPasswordEditKeyErrorNoKey,
  MPPasswordEditKeyErrorNotReachable,
  MPPasswordEditKeyErrorIsCurrentDatabase,
  MPPasswordEditKeyErrorIsKeePassDatabase,
};


@interface MPPasswordEditWindowController ()

@property (nonatomic, assign) BOOL showPassword;
@property (nonatomic, assign) BOOL enablePassword;
@property (nonatomic, assign) BOOL hasValidPasswordOrKey;
@property (weak) NSGridRow *passwordErrorGridRow;
@property (weak) NSGridRow *keyErrorGridRow;

@end

@implementation MPPasswordEditWindowController

- (NSString *)windowNibName {
  return @"PasswordEditWindow";
}

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if(self){
    _showPassword = NO;
    _hasValidPasswordOrKey = NO;
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didChangeKeyURL:) name:MPPathControlDidSetURLNotification object:self.keyfilePathControl];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  self.window.defaultButtonCell = self.changePasswordButton.cell;
  MPDocument *document = self.document;
  self.enablePassword = [document.compositeKey hasKeyOfClass:KPKPasswordKey.class];
  
  self.passwordErrorGridRow = [self.gridView cellForView:self.passwordErrorTextField].row;
  self.keyErrorGridRow = [self.gridView cellForView:self.keyErrorTextField].row;
}

- (void)updateView {
  if(!self.isDirty) {
    return;
  }
  self.showPassword = NO;
  
  NSDictionary *negateOption = @{ NSValueTransformerNameBindingOption : NSNegateBooleanTransformerName };
  NSString *enablePasswordKeyPath = NSStringFromSelector(@selector(enablePassword));
  NSString *showPasswordKeyPath = NSStringFromSelector(@selector(showPassword));
  NSString *hasValidPasswordOrKeyKeyPath = NSStringFromSelector(@selector(hasValidPasswordOrKey));
  
  [self.hasPasswordSwitchButton bind:NSValueBinding toObject:self withKeyPath:enablePasswordKeyPath options:nil];
  [self.passwordTextField bind:showPasswordKeyPath toObject:self withKeyPath:showPasswordKeyPath options:nil];
  [self.passwordTextField bind:NSEnabledBinding toObject:self withKeyPath:enablePasswordKeyPath options:nil];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:showPasswordKeyPath options:nil];
  [self.togglePasswordButton bind:NSEnabledBinding toObject:self withKeyPath:enablePasswordKeyPath options:nil];
  [self.passwordRepeatTextField bind:NSEnabledBinding toObject:self withKeyPath:showPasswordKeyPath options:negateOption];
  [self.passwordRepeatTextField bind:NSEnabledBinding toObject:self withKeyPath:enablePasswordKeyPath options:nil];

  [self.changePasswordButton bind:NSEnabledBinding toObject:self withKeyPath:hasValidPasswordOrKeyKeyPath options:nil];
  
  self.passwordRepeatTextField.delegate = self;
  self.passwordTextField.delegate = self;
  
  /* Manually initate the first check */
  [self _verifyPasswordAndKey];
  self.isDirty = NO;
}

#pragma mark Properties
- (void)setShowPassword:(BOOL)showPassword {
  if(_showPassword != showPassword) {
    _showPassword = showPassword;
    
    self.passwordRepeatTextField.stringValue = @"";
    [self _verifyPasswordAndKey];
  }
}

- (void)setEnablePassword:(BOOL)enablePassword {
  if(_enablePassword != enablePassword) {
    _enablePassword = enablePassword;
  }
  NSString *passwordPlaceHolder = _enablePassword ? NSLocalizedString(@"PASSWORD_INPUT_ENTER_PASSWORD", "Placeholder for the password field to aks for password") : NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "Placeholder for the password input field if passwords are disabled");
  NSString *repeatPlaceHolder = _enablePassword ? NSLocalizedString(@"PASSWORD_INPUT_REPEAT_PASSWORD", "Placeholder for the repeat password field to aks for the repeated password") : NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "Placeholder for the repeat password input if passwords are disabled");
  self.passwordTextField.placeholderString = passwordPlaceHolder;
  self.passwordRepeatTextField.placeholderString = repeatPlaceHolder;
  [self _verifyPasswordAndKey];
}

#pragma mark Actions
- (IBAction)save:(id)sender {
  /* TODO: Move to a more generalized aproach to initalize the composite key and set it via a MPDocument API */
  const BOOL hasPassword = HNHUIBoolForState(self.hasPasswordSwitchButton.state);
  NSString *password = hasPassword ? self.passwordTextField.stringValue : nil;
  MPDocument *document = self.document;
  [document changePassword:password keyFileURL:self.keyfilePathControl.URL];
  [self dismissSheet:NSModalResponseOK];
}

- (IBAction)cancel:(id)sender {
  [self dismissSheet:NSModalResponseCancel];
}

- (IBAction)clearKey:(id)sender {
  self.keyfilePathControl.URL = nil;
}

- (IBAction)generateKey:(id)sender {
  MPDocument *document = self.document;
  NSData *data = [NSData kpk_generateKeyfileDataForFormat:document.tree.minimumVersion.format];
  if(data) {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"key", @"xml"];
    savePanel.canCreateDirectories = YES;
    savePanel.title = NSLocalizedString(@"SAVE_KEYFILE", "Button title to save the generated key file");
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
      if(result == NSModalResponseOK) {
        NSURL *keyURL = [savePanel URL];
        NSError *error;
        BOOL saveOk = [data writeToURL:keyURL options:NSDataWritingAtomic error:&error];
        if(saveOk) {
          self.keyfilePathControl.URL = keyURL;
        }
      }
    }];
  }
}

#pragma mark NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
  [self _verifyPasswordAndKey];
}

#pragma mark Notifications
- (void)_didChangeKeyURL:(NSNotification *)notification {
  if(notification.object != self.keyfilePathControl) {
    return;
  }
  [self _verifyPasswordAndKey];
}


#pragma mark UI update
- (void)_verifyPasswordAndKey {
  self.passwordErrorGridRow.hidden = YES;
  self.keyErrorGridRow.hidden = YES;

  self.keyErrorTextField.stringValue = @"";
  self.passwordErrorTextField.stringValue = @"";
  
  MPPasswordEditKeyError keyError = [self _verifyKey];
  MPPasswordEditPasswordError passwordError = [self _verifyPassword];
  
  self.keyErrorTextField.textColor = NSColor.controlTextColor;
  self.passwordErrorTextField.textColor = NSColor.controlTextColor;
  
  if(keyError == MPPasswordEditKeyErrorNoKey && passwordError == MPPasswordEditPasswordErrorNoPassword) {

    self.passwordErrorTextField.stringValue = NSLocalizedString(@"WARNING_NO_PASSWORD", "Warning if no password is set when chaning the password");
    self.passwordErrorGridRow.hidden = NO;
    
    self.keyErrorTextField.stringValue = NSLocalizedString(@"WARNING_NO_KEYFILE", "Warning tha no key file is set when chaning the password");
    self.keyErrorGridRow.hidden = NO;
    
    return;
  }
    
  switch(keyError) {
    case MPPasswordEditKeyErrorNotReachable:
      self.keyErrorTextField.stringValue = NSLocalizedString(@"ERROR_KEYFILE_NOT_FOUND", "Keyfile was not found");
      self.keyErrorTextField.textColor = NSColor.redColor;
      self.keyErrorGridRow.hidden = NO;
      break;
    case MPPasswordEditKeyErrorIsCurrentDatabase:
      self.keyErrorTextField.stringValue = NSLocalizedString(@"WARNING_CURRENT_DATABASE_FILE_SELECTED_AS_KEY_FILE", "Error message displayed when the current database file is also set as the key file");
      self.keyErrorTextField.textColor = NSColor.redColor;
      self.keyErrorGridRow.hidden = NO;
      break;
    case MPPasswordEditKeyErrorIsKeePassDatabase:
      self.keyErrorTextField.stringValue = NSLocalizedString(@"WARNING_DATABASE_FILE_SELECTED_AS_KEY_FILE", "Error message displayed when a keepass database file is set as the key file");
      self.keyErrorTextField.textColor = NSColor.redColor;
      self.keyErrorGridRow.hidden = NO;
      break;
    case MPPasswordEditKeyErrorNoKey:
      if(!self.enablePassword) {
        self.keyErrorTextField.stringValue = NSLocalizedString(@"WARNING_NO_KEYFILE", "No key file is set");
        self.keyErrorGridRow.hidden = NO;
      }
      keyError = MPPasswordEditKeyErrorNone; // remove the error
      break;
    case MPPasswordEditKeyErrorNone:
      break;
  }
  
  switch(passwordError) {
    case MPPasswordEditPasswordErrorRepeatMissmatch:
      self.passwordErrorTextField.stringValue = NSLocalizedString(@"ERROR_PASSWORD_MISSMATCH", "Passwords do not match");
      self.passwordErrorTextField.textColor = NSColor.redColor;
      self.passwordErrorGridRow.hidden = NO;
      break;
    case MPPasswordEditPasswordErrorNone:
    case MPPasswordEditPasswordErrorNoPassword:
      break;
  }
  
  self.hasValidPasswordOrKey = (passwordError == MPPasswordEditPasswordErrorNone && keyError == MPPasswordEditKeyErrorNone);
}

- (MPPasswordEditKeyError)_verifyKey {
  NSURL *keyURL = self.keyfilePathControl.URL;
  if(!keyURL) {
    return MPPasswordEditKeyErrorNoKey;
  }
  
  if(![keyURL checkResourceIsReachableAndReturnError:nil]) {
    return MPPasswordEditKeyErrorNotReachable;
  }
  /* TODO: exten KPKFileKey to do database checks internally */
  NSDocument *document = (NSDocument *)self.document;
  NSData *keyFileData = [NSData dataWithContentsOfURL:keyURL];
  KPKFileVersion keyFileVersion = [KPKFormat.sharedFormat fileVersionForData:keyFileData];
  if(keyFileVersion.format != KPKDatabaseFormatUnknown) {
    if([document.fileURL isEqual:keyURL]) {
      return MPPasswordEditKeyErrorIsCurrentDatabase;
    }
    return MPPasswordEditKeyErrorIsKeePassDatabase;
  }
  /* FIXME: check xml key */
  return MPPasswordEditKeyErrorNone;
}

- (MPPasswordEditPasswordError)_verifyPassword {

  if(!self.enablePassword) {
    return MPPasswordEditPasswordErrorNone;
  }
  
  NSString *password = self.passwordTextField.stringValue;
  NSString *repeat = self.passwordRepeatTextField.stringValue;

  if(self.showPassword) {
    if(password.kpk_isNotEmpty) {
      return MPPasswordEditPasswordErrorNone;
    }
    return MPPasswordEditPasswordErrorNoPassword;
  }

  if(!password.kpk_isNotEmpty && !repeat.kpk_isNotEmpty) {
    return MPPasswordEditPasswordErrorNoPassword;
  }
  
  if(![password isEqualToString:repeat]) {
    return MPPasswordEditPasswordErrorRepeatMissmatch;
  }
  return MPPasswordEditPasswordErrorNone;
}

@end
