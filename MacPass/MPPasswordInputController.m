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
#import "MPSettingsHelper.h"
#import "MPPathControl.h"
#import "MPTouchBarButtonCreator.h"
#import "MPSettingsHelper.h"

#import "HNHUi/HNHUi.h"

#import "NSError+Messages.h"

static NSMutableDictionary* touchIDSecuredPasswords;

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
@property (weak) IBOutlet NSButton *touchIdEnabled;

@property (copy) NSString *message;
@property (copy) NSString *cancelLabel;
@property (copy) NSString *absoluteURLString;

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
    if(touchIDSecuredPasswords == NULL) {
      touchIDSecuredPasswords = [[NSMutableDictionary alloc]init];
    }
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
  self.touchIdEnabled.hidden = true;
  if (@available(macOS 10.13.4, *)) {
    self.touchIdEnabled.hidden = false;
    self.touchIdEnabled.state = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyEntryTouchIdEnabled];
  }
  [self _reset];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (void)requestPasswordWithMessage:(NSString *)message cancelLabel:(NSString *)cancelLabel completionHandler:(passwordInputCompletionBlock)completionHandler forFile:(NSURL*) fileURL{
  self.completionHandler = completionHandler;
  self.message = message;
  self.cancelLabel = cancelLabel;
  if(fileURL) {
      self.absoluteURLString = [fileURL absoluteString];
  }
  else {
    self.absoluteURLString = nil;
  }
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
  KPKCompositeKey *compositeKey = [[KPKCompositeKey alloc] initWithPassword:password keyFileData:keyFileData];
  BOOL result = self.completionHandler(compositeKey, keyURL, cancel, &error);
  if(cancel || result) {
    if(result && self.keyPathControl.URL == nil && self.touchIdEnabled.state) {
      [self _storePasswordForTouchIDUnlock:password forDatabase:self.absoluteURLString];
    }
    return;
  }
  [self _showError:error];
  /* do not shake if we are a sheet */
  if(!self.view.window.isSheet) {
    [self.view.window shakeWindow:nil];
  }
}

- (void) _createAndAddRSAKeyPair {
  CFErrorRef error = NULL;
  NSString* publicKeyLabel =  @"MacPass TouchID Feature Public Key";
  NSString* privateKeyLabel = @"MacPass TouchID Feature Private Key";
  NSData* publicKeyTag =  [@"com.hicknhacksoftware.macpass.publickey"  dataUsingEncoding:NSUTF8StringEncoding];
  NSData* privateKeyTag = [@"com.hicknhacksoftware.macpass.privatekey" dataUsingEncoding:NSUTF8StringEncoding];
  SecAccessControlRef access = NULL;
  if (@available(macOS 10.13.4, *)) {
    access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                             kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                             kSecAccessControlBiometryCurrentSet,
                                             &error);
    if(access == NULL) {
      NSError *err = CFBridgingRelease(error);
      NSLog(@"Error while trying to create AccessControl for TouchID unlock feature: %@", [err description]);
      return;
    }
    NSDictionary* attributes = @{
      (id)kSecAttrKeyType:        (id)kSecAttrKeyTypeRSA,
      (id)kSecAttrKeySizeInBits:  @2048,
      (id)kSecAttrSynchronizable: @NO,
      (id)kSecPrivateKeyAttrs:
           @{ (id)kSecAttrIsPermanent:    @YES,
              (id)kSecAttrApplicationTag: privateKeyTag,
              (id)kSecAttrLabel: privateKeyLabel,
              (id)kSecAttrAccessControl:  (__bridge id)access
            },
      (id)kSecPublicKeyAttrs:
           @{ (id)kSecAttrIsPermanent:    @YES,
              (id)kSecAttrApplicationTag: publicKeyTag,
              (id)kSecAttrLabel: publicKeyLabel,
            },
    };
    SecKeyRef privateKey = NULL;
    SecKeyRef publicKey = NULL;
    OSStatus result = SecKeyGeneratePair((__bridge CFDictionaryRef)attributes, &privateKey, &publicKey);
    if(result == errSecSuccess) {
      CFRelease(publicKey);
      CFRelease(privateKey);
    }
    else {
      NSString* description = (__bridge NSString*)SecCopyErrorMessageString(result, NULL);
      NSLog(@"Error while trying to create a RSA keypair for TouchID unlock feature: %@", description);
    }
  }
  else {
    return;
  }
}

- (void) _storePasswordForTouchIDUnlock: (NSString*) password forDatabase: (NSString*) databaseId {
  NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
  NSData* tag = [@"com.hicknhacksoftware.macpass.publickey" dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *getquery = @{
    (id)kSecClass: (id)kSecClassKey,
    (id)kSecAttrApplicationTag: tag,
    (id)kSecReturnRef: @YES,
  };
  SecKeyRef publicKey = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery, (CFTypeRef *)&publicKey);
  if (status != errSecSuccess) {
    [self _createAndAddRSAKeyPair];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery, (CFTypeRef *)&publicKey);
    if (status != errSecSuccess) {
      NSString* description = (__bridge NSString*)SecCopyErrorMessageString(status, NULL);
      NSLog(@"Error while trying to query public key from Keychain: %@", description);
      return;
    }
  }
  SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA512;
  BOOL canEncrypt = SecKeyIsAlgorithmSupported(publicKey, kSecKeyOperationTypeEncrypt, algorithm);
  if(canEncrypt) {
    int k = (int)SecKeyGetBlockSize(publicKey);
    int hlen = 512 / 8;
    int maxMessageLengthInByte = k - 2 * hlen - 2;
    if([passwordData length] <= maxMessageLengthInByte) {
      CFErrorRef error = NULL;
      NSData* cipherText = (NSData*)CFBridgingRelease(SecKeyCreateEncryptedData(publicKey, algorithm, (__bridge CFDataRef)passwordData, &error));
      if (cipherText) {
        [touchIDSecuredPasswords setObject:cipherText forKey:databaseId];
      }
      else {
        NSError *err = CFBridgingRelease(error);
        NSLog(@"Error while trying decrypt password for TouchID unlock: %@", [err description]);
      }
    }
    else {
      NSLog(@"The password is too large to be encrypted");
      return;
    }
  }
  else {
      NSLog(@"The key retreived from the Keychain is unable to encrypt data");
  }
  if (publicKey)  { CFRelease(publicKey);  }
}

- (NSString*) _loadPasswordForTochIDUnlock: (NSString*) databaseId {
  NSString* result = nil;
  NSData* cipherText = [touchIDSecuredPasswords valueForKey:databaseId];
  if(cipherText != nil) {
    NSData* tag = [@"com.hicknhacksoftware.macpass.privatekey" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *queryPrivateKey = @{
      (id)kSecClass: (id)kSecClassKey,
      (id)kSecAttrApplicationTag: tag,
      (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
      (id)kSecReturnRef: @YES,
    };
    SecKeyRef privateKey = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
    if (status == errSecSuccess) {
      SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA512;
      BOOL canDecrypt = SecKeyIsAlgorithmSupported(privateKey, kSecKeyOperationTypeDecrypt, algorithm);
      if(canDecrypt) {
        if([cipherText length] == SecKeyGetBlockSize(privateKey)) {
          CFErrorRef error = NULL;
          NSData* clearText = (NSData*)CFBridgingRelease(SecKeyCreateDecryptedData(privateKey, algorithm, (__bridge CFDataRef)cipherText, &error));
          if (clearText) {
            result = [[NSString alloc]initWithData:clearText encoding:NSUTF8StringEncoding];
          }
          else {
            NSError *err = CFBridgingRelease(error);
            NSLog(@"Error while trying to decrypt password for TouchID unlock: %@", [err description]);
          }
        }
        else {
          NSLog(@"Block size of the cipher text has a unexpected value: %lu", (unsigned long)[cipherText length]);
        }
      }
      else {
        NSLog(@"Key does not support decryption");
      }
    }
    else {
      NSString* description = (__bridge NSString*)SecCopyErrorMessageString(status, NULL);
      NSLog(@"Error while trying to retrive private key for decryption: %@", description);
    }
    if (privateKey) {
      CFRelease(privateKey);
    }
  }
  return result;
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
- (IBAction)touchIdEnabledChanged:(id)sender {
    [NSUserDefaults.standardUserDefaults setBool:self.touchIdEnabled.state forKey:kMPSettingsKeyEntryTouchIdEnabled];
}

- (void)_reset {
  self.showPassword = NO;
  self.enablePassword = YES;
  self.passwordTextField.stringValue = @"";
  self.messageInfoTextField.hidden = (nil == self.message);
  self.touchIdButton.hidden = [touchIDSecuredPasswords valueForKey:self.absoluteURLString] == nil;
    
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

- (IBAction)unlockWithTouchID:(id)sender {
  NSString* password = [self _loadPasswordForTochIDUnlock:self.absoluteURLString];
  if(password != nil) {
    NSError* error;
    KPKCompositeKey *compositeKey = [[KPKCompositeKey alloc] initWithPassword:password keyFileData:nil];
    self.completionHandler(compositeKey, nil, false, &error);
    [self _showError:error];
  }
}

@end
