//
//  MPPasswordEditWindowController.m
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordEditWindowController.h"
#import "MPDocument.h"

#import "HNHRoundedSecureTextField.h"
#import "NSString+Empty.h"
#import "NSData+Keyfile.h"

#import "KPKTree.h"
#import "KPKCompositeKey.h"

@interface MPPasswordEditWindowController ()

@property (nonatomic, weak) MPDocument *currentDocument;
@property (nonatomic, assign) BOOL showPassword;
@property (nonatomic, assign) BOOL enablePassword;
@property (nonatomic, assign) BOOL hasValidPasswordOrKey;
@property (nonatomic, weak) NSURL *keyURL;

@end

@implementation MPPasswordEditWindowController

- (NSString *)windowNibName {
  return @"PasswordEditWindow";
}

- (id)initWithDocument:(MPDocument *)document {
  self = [super init];
  if(self){
    _allowsEmptyPasswordOrKey = YES;
    _showPassword = NO;
    _hasValidPasswordOrKey = NO;
    _currentDocument = document;
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [[self window] setDefaultButtonCell:[self.changePasswordButton cell]];
  self.enablePassword = _currentDocument.compositeKey.hasPassword;
}

- (void)updateView {
  if(!self.isDirty) {
    return;
  }
  self.showPassword = NO;
  // TODO: fix initial view for password edit
  //[self.passwordTextField setStringValue:_currentDocument.password ? _currentDocument.password : @""];
  //[self.passwordRepeatTextField setStringValue:[self.passwordTextField stringValue]];
  //self.keyURL = _currentDocument.key;
  
  NSDictionary *negateOption = @{ NSValueTransformerNameBindingOption : NSNegateBooleanTransformerName };
  [self.hasPasswordSwitchButton bind:NSValueBinding toObject:self withKeyPath:@"enablePassword" options:nil];
  [self.passwordTextField bind:NSStringFromSelector(@selector(showPassword)) toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.passwordTextField bind:NSEnabledBinding toObject:self withKeyPath:@"enablePassword" options:nil];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.togglePasswordButton bind:NSEnabledBinding toObject:self withKeyPath:@"enablePassword" options:nil];
  [self.passwordRepeatTextField bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:negateOption];
  [self.passwordRepeatTextField bind:NSEnabledBinding toObject:self withKeyPath:@"enablePassword" options:nil];
  [self.errorTextField bind:NSHiddenBinding toObject:self withKeyPath:@"hasValidPasswordOrKey" options:nil];
  [self.changePasswordButton bind:NSEnabledBinding toObject:self withKeyPath:@"hasValidPasswordOrKey" options:nil];
  [self.keyfilePathControl bind:NSValueBinding toObject:self withKeyPath:@"keyURL" options:nil];
  
  [self.passwordRepeatTextField setDelegate:self];
  [self.passwordTextField setDelegate:self];
  
  /* Manually initate the first check */
  [self _verifyPasswordAndKey];
  self.isDirty = NO;
}

#pragma mark Properties
- (void)setShowPassword:(BOOL)showPassword {
  if(_showPassword != showPassword) {
    _showPassword = showPassword;
    
    [self.passwordRepeatTextField setStringValue:@""];
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
  NSString *passwordPlaceHolder = _enablePassword ? NSLocalizedString(@"PASSWORD_INPUT_ENTER_PASSWORD", "") : NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "");
  NSString *repeatPlaceHolder = _enablePassword ? NSLocalizedString(@"PASSWORD_INPUT_REPEAT_PASSWORD", "") : NSLocalizedString(@"PASSWORD_INPUT_NO_PASSWORD", "");
  [[self.passwordTextField cell] setPlaceholderString:passwordPlaceHolder];
  [[self.passwordRepeatTextField cell] setPlaceholderString:repeatPlaceHolder];
}

#pragma mark Actions
- (IBAction)save:(id)sender {
  const BOOL hasPassword = ([self.hasPasswordSwitchButton state] == NSOnState);
  NSString *password = hasPassword ? [self.passwordTextField stringValue] : nil;
  [_currentDocument changePassword:password keyFileURL:[self.keyfilePathControl URL]];
  [self dismissSheet:NSRunStoppedResponse];
  if(self.delegate && [self.delegate respondsToSelector:@selector(didFinishPasswordEditing:)]) {
    [self.delegate didFinishPasswordEditing:YES];
  }
}

- (IBAction)cancel:(id)sender {
  [self dismissSheet:NSRunAbortedResponse];
  if(self.delegate && [self.delegate respondsToSelector:@selector(didFinishPasswordEditing:)]) {
    [self.delegate didFinishPasswordEditing:NO];
  }
}

- (IBAction)clearKey:(id)sender {
  self.keyURL = nil;
}

- (IBAction)generateKey:(id)sender {
  NSData *data = [NSData generateKeyfiledataForVersion:_currentDocument.tree.minimumVersion];
  if(data) {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"key", @"xml"]];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setTitle:NSLocalizedString(@"SAVE_KEYFILE", "")];
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
  NSString *password = [self.passwordTextField stringValue];
  NSString *repeat = [self.passwordRepeatTextField stringValue];
  BOOL hasKey = (self.keyURL != nil);
  BOOL keyOk = YES;
  if(hasKey) {
    keyOk = [self.keyURL checkResourceIsReachableAndReturnError:nil];
  }
  BOOL hasPassword = ![NSString isEmptyString:password];
  if(!self.showPassword) {
    hasPassword |= ![NSString isEmptyString:repeat];
  }
  BOOL passwordOk = YES;
  if(hasPassword ) {
    passwordOk = [password isEqualToString:repeat] || self.showPassword;
  }
  BOOL hasPasswordOrKey = (hasKey || hasPassword);
  keyOk = hasKey ? keyOk : YES;
  passwordOk = hasPassword ? passwordOk : YES;
  self.hasValidPasswordOrKey = (hasPasswordOrKey || self.allowsEmptyPasswordOrKey ) && passwordOk && keyOk;
  
  if(!hasPasswordOrKey) {
    [self.errorTextField setTextColor:[NSColor controlTextColor]];
    [self.errorTextField setStringValue:NSLocalizedString(@"WARNING_NO_PASSWORD_OR_KEYFILE", "No Key or Password")];
    return; // alldone
  }
  [self.errorTextField setTextColor:[NSColor redColor]];
  if(!passwordOk && !keyOk ) {
    [self.errorTextField setStringValue:NSLocalizedString(@"ERROR_PASSWORD_MISSMATCH_INVALID_KEYFILE", "Passwords do not match, keyfile is invalid")];
  }
  else if(!passwordOk) {
    [self.errorTextField setStringValue:NSLocalizedString(@"ERROR_PASSWORD_MISSMATCH", "Passwords do not match")];
  }
  else {
    [self.errorTextField setStringValue:NSLocalizedString(@"ERROR_INVALID_KEYFILE", "Keyfile not valid")];
  }
}


@end
