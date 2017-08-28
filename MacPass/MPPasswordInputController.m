//
//  MPPasswordInputController.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordInputController.h"
#import "MPAppDelegate.h"
#import "MPDocumentWindowController.h"
#import "MPDocument.h"
#import "MPSettingsHelper.h"
#import "MPKeyfilePathControlDelegate.h"

#import "HNHUi/HNHUi.h"

#import "NSError+Messages.h"

@import LocalAuthentication;
#import "MacPass-Swift.h"
#import "MPOSHelper.h"

@interface MPPasswordInputController ()

@property (weak) IBOutlet HNHUIRoundedSecureTextField *passwordTextField;
@property (weak) IBOutlet NSPathControl *keyPathControl;
@property (strong) MPKeyfilePathControlDelegate *pathControlDelegate;
@property (weak) IBOutlet NSImageView *errorImageView;
@property (weak) IBOutlet NSTextField *errorInfoTextField;
@property (weak) IBOutlet NSButton *togglePasswordButton;
@property (weak) IBOutlet NSButton *enablePasswordCheckBox;

@property (assign) BOOL showPassword;
@property (nonatomic, assign) BOOL enablePassword;
@property (copy) passwordInputCompletionBlock completionHandler;

@property (weak) IBOutlet NSButton *useTouchIdButton;
@property (nonatomic, readonly) NSString *databaseName;
@end

@implementation MPPasswordInputController

- (NSString *)nibName {
  return @"PasswordInputView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _enablePassword = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectKeyURL) name:MPDidChangeStoredKeyFilesSettings object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  self.keyPathControl.delegate = self.pathControlDelegate;
  self.errorImageView.image = [NSImage imageNamed:NSImageNameCaution];
  [self.passwordTextField bind:NSStringFromSelector(@selector(showPassword)) toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.enablePasswordCheckBox bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enablePassword)) options:nil];
  [self.togglePasswordButton bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enablePassword)) options:nil];
  [self.passwordTextField bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enablePassword)) options:nil];
  [self _reset];
}

-(void)viewDidAppear {
	[super viewDidAppear];
	[self _enableTouchID]; //Maybe call this when the password text field is focused and not on viewDidAppear...
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (void)requestPasswordWithCompletionHandler:(passwordInputCompletionBlock)completionHandler {
  self.completionHandler = completionHandler;
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
  NSString *placeHolderString = _enablePassword ? NSLocalizedString(@"PASSWORD_INPUT_ENTER_PASSWORD", "") : NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "");
  ((NSTextFieldCell *)self.passwordTextField.cell).placeholderString = placeHolderString;
}

- (NSString*) databaseName {
	MPDocumentWindowController *documentWindow = self.windowController;
	MPDocument *document = documentWindow.document;
	return document.displayName;
}

#pragma mark -
#pragma mark Private
- (IBAction)_submit:(id)sender {
  if(self.completionHandler) {
    /* No password is different than an empty password */
    NSError *error = nil;
    NSString *password = self.enablePassword ? self.passwordTextField.stringValue : nil;
    if(!self.completionHandler(password, self.keyPathControl.URL, &error)) {
      [self _showError:error];
      [self.view.window shakeWindow:nil];
    }
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
  self.errorInfoTextField.hidden = YES;
  self.errorImageView.hidden = YES;
  [self resetKeyFile:self];
}

- (void)_selectKeyURL {
  MPDocument *document = self.windowController.document;
  self.keyPathControl.URL = document.suggestedKeyURL;
}

- (void)_showError:(NSError *)error {
  if(error) {
    self.errorInfoTextField.stringValue = error.descriptionForErrorCode;
  }
  self.errorImageView.hidden = NO;
  self.errorInfoTextField.hidden = NO;
}

- (IBAction)showTouchIdDialog:(id)sender {
	[self _enableTouchID];
}

- (void)_enableTouchID {

	if (![MPSettingsHelper.touchIdEnabledDatabases containsObject:self.databaseName]) {
		[_useTouchIdButton setEnabled:NO];
		return; //Do not ask for TouchID if its not enabled for this database.
	}

	if (MPOSHelper.supportsTouchID) {
		LAContext *myContext = [LAContext new];
		NSString *myLocalizedReasonString = NSLocalizedString(@"TOUCHBAR_TOUCH_ID_MESSAGE", @"");
		[myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:myLocalizedReasonString reply:^(BOOL success, NSError * _Nullable error) {
			if (success) {
				// User authenticated successfully, take appropriate action
				NSLog(@"User authentication sucessful! Getting password from the keychain...");
				[self _getPasswordFromKeychain];
			} else {
				// User did not authenticate successfully, look at error and take appropriate action
				NSLog(@"User authentication failed. %@", error.localizedDescription);
			}
		}];
	} else {
		NSLog(@"TouchID is not supported.");
	}
}

- (void) _getPasswordFromKeychain {
	KeychainPasswordItem *passwordItem = [[KeychainPasswordItem alloc] initWithService: @"MacPass" account:self.databaseName accessGroup:nil];
	__autoreleasing NSError *err = nil;

	NSString *pass = [passwordItem readPasswordAndReturnError:&err];
	if (err != nil) {
		NSLog(@"Could not retrieve DB password from the keychain:");
	} else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			_passwordTextField.stringValue = pass;
			[self _submit:nil];
		});
	}

}



@end
