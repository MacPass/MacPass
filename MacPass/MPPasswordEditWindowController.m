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

#import "HNHUi/HNHUi.h"

#import "KeePassKit/KeePassKit.h"

@interface MPPasswordEditWindowController ()

@property (nonatomic, assign) BOOL showPassword;
@property (nonatomic, assign) BOOL enablePassword;
@property (nonatomic, assign) BOOL hasValidPasswordOrKey;
@property (nonatomic, weak) NSURL *keyURL;

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
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  self.window.defaultButtonCell = self.changePasswordButton.cell;
  MPDocument *document = self.document;
  self.enablePassword = document.compositeKey.hasPassword;
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
  [self.errorTextField bind:NSHiddenBinding toObject:self withKeyPath:hasValidPasswordOrKeyKeyPath options:nil];
  [self.changePasswordButton bind:NSEnabledBinding toObject:self withKeyPath:hasValidPasswordOrKeyKeyPath options:nil];
  [self.keyfilePathControl bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(keyURL)) options:nil];
  
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
- (void)setKeyURL:(NSURL *)keyURL {
  _keyURL = keyURL;
  [self _verifyPasswordAndKey];
}
- (void)setEnablePassword:(BOOL)enablePassword {
  if(_enablePassword != enablePassword) {
    _enablePassword = enablePassword;
  }
  NSString *passwordPlaceHolder = _enablePassword ? NSLocalizedString(@"PASSWORD_INPUT_ENTER_PASSWORD", "Placeholder for the password field to aks for password") : NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "Placeholder for the password input field if passwords are disabled");
  NSString *repeatPlaceHolder = _enablePassword ? NSLocalizedString(@"PASSWORD_INPUT_REPEAT_PASSWORD", "Placeholder for the repeat password field to aks for the repeated password") : NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "Placeholder for the repeat password input if passwords are disabled");
  self.passwordTextField.placeholderString = passwordPlaceHolder;
  self.passwordRepeatTextField.placeholderString = repeatPlaceHolder;
}

#pragma mark Actions
- (IBAction)save:(id)sender {
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
  self.keyURL = nil;
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
      if(result == NSFileHandlingPanelOKButton) {
        NSURL *keyURL = [savePanel URL];
        NSError *error;
        BOOL saveOk = [data writeToURL:keyURL options:NSDataWritingAtomic error:&error];
        if(saveOk) {
          self.keyURL = keyURL;
        }
      }
    }];
  }
}

#pragma mark NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
  [self _verifyPasswordAndKey];
}

- (void)_verifyPasswordAndKey {
  NSString *password = self.passwordTextField.stringValue;
  NSString *repeat = self.passwordRepeatTextField.stringValue;
  BOOL hasKey = (self.keyURL != nil);
  BOOL keyOk = YES;
  if(hasKey) {
    keyOk = [self.keyURL checkResourceIsReachableAndReturnError:nil];
  }
  BOOL hasPassword = password.kpk_isNotEmpty;
  if(!self.showPassword) {
    hasPassword |= repeat.kpk_isNotEmpty;
  }
  BOOL passwordOk = YES;
  if(hasPassword ) {
    passwordOk = [password isEqualToString:repeat] || self.showPassword;
  }
  BOOL hasPasswordOrKey = (hasKey || hasPassword);
  keyOk = hasKey ? keyOk : YES;
  passwordOk = hasPassword ? passwordOk : YES;
  self.hasValidPasswordOrKey = hasPasswordOrKey && passwordOk && keyOk;
  
  if(!hasPasswordOrKey) {
    self.errorTextField.textColor = NSColor.controlTextColor;
    self.errorTextField.stringValue = NSLocalizedString(@"WARNING_NO_PASSWORD_OR_KEYFILE", "No Key or Password");
    return; // all done
  }
  self.errorTextField.textColor = NSColor.redColor;
  if(!passwordOk && !keyOk ) {
    self.errorTextField.stringValue = NSLocalizedString(@"ERROR_PASSWORD_MISSMATCH_INVALID_KEYFILE", "Passwords do not match, keyfile is invalid");
  }
  else if(!passwordOk) {
    self.errorTextField.stringValue = NSLocalizedString(@"ERROR_PASSWORD_MISSMATCH", "Passwords do not match");
  }
  else {
    self.errorTextField.stringValue = NSLocalizedString(@"ERROR_INVALID_KEYFILE", "Keyfile not valid");
  }
}


@end
