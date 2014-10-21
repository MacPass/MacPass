//
//  PasswordCreatorView.m
//  MacPass
//
//  Created by Michael Starke on 31.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordCreatorViewController.h"
#import "MPPasteBoardController.h"
#import "NSString+MPPasswordCreation.h"
#import "MPUniqueCharactersFormatter.h"
#import "MPSettingsHelper.h"

/*
 
 0 - 20 Terrible
 21 - 31 Weak
 32 - 55 Good
 56 - 85 Excellent
 85 - Fantastic
 
 Skale 0-90
 */
typedef NS_ENUM(NSUInteger, MPPasswordRating) {
  MPPasswordTerrible = 10,
  MPPasswordWeak = 20,
  MPPasswordOk = 30,
  MPPasswordGood = 50,
  MPPasswordStrong = 60
};

typedef NS_ENUM(NSUInteger, MPDefaultDomain) {
  MPEntryDomain,
  MPGlobalDomain,
};

#define MIN_PASSWORD_LENGTH 1
#define MAX_PASSWORD_LENGTH 256

@interface MPPasswordCreatorViewController () {
  MPPasswordCharacterFlags _characterFlags;
  MPDefaultDomain _defaultDomain;
}
@property (nonatomic, copy) NSString *password;
@property (copy) NSString *generatedPassword;

@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSTextField *passwordLengthTextField;
@property (weak) IBOutlet NSTextField *customCharactersTextField;
@property (weak) IBOutlet NSSlider *passwordLengthSlider;
@property (weak) IBOutlet NSButton *shouldCopyPasswordToPasteboardButton;
@property (weak) IBOutlet NSButton *upperCaseButton;
@property (weak) IBOutlet NSButton *lowerCaseButton;
@property (weak) IBOutlet NSButton *numbersButton;
@property (weak) IBOutlet NSButton *symbolsButton;
@property (weak) IBOutlet NSButton *customButton;
@property (weak) IBOutlet NSButton *setDefaultButton;
@property (weak) IBOutlet NSTextField *entropyTextField;
@property (weak) IBOutlet NSLevelIndicator *entropyIndicator;

@property (nonatomic, copy) NSString *customString;
@property (nonatomic, assign) BOOL useCustomString;
@property (nonatomic, assign) NSUInteger passwordLength;
@property (nonatomic, assign) CGFloat entropy;

@end

@implementation MPPasswordCreatorViewController

- (NSString *)nibName {
  return @"PasswordCreatorView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _password = @"";
    _passwordLength = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDefaultPasswordLength];
    _characterFlags = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyPasswordCharacterFlags];
    _useCustomString = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyPasswordUseCustomString];
    _customString = [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyPasswordCustomString];
    _entropy = 0.0;
    _defaultDomain = MPGlobalDomain;
    _allowsEntryDefaults = NO;
  }
  return self;
}

- (void)awakeFromNib {
  [self.setDefaultButton setEnabled:NO];
  
  [self.passwordLengthSlider setMinValue:MIN_PASSWORD_LENGTH];
  [self.passwordLengthSlider setMaxValue:MAX_PASSWORD_LENGTH];
  [self.passwordLengthSlider setContinuous:YES];
  
  [self.customCharactersTextField setStringValue:_customString];
  
  /* Value Transformer */
  
  id formatter = [[MPUniqueCharactersFormatter alloc] init];
  [self. customCharactersTextField setFormatter:formatter];
  
  [self.passwordLengthSlider bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(passwordLength)) options:nil];
  [self.passwordLengthTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(passwordLength)) options:nil];
  [self.passwordTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(password)) options:nil];
  
  [self.entropyIndicator bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(entropy)) options:nil];
  [self.entropyTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(entropy)) options:nil];
  
  [self.customCharactersTextField setDelegate:self];
  [self.customButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(useCustomString)) options:nil];
  
  NSString *copyToPasteBoardKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyCopyGeneratedPasswordToClipboard];
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  [self.shouldCopyPasswordToPasteboardButton bind:NSValueBinding toObject:defaultsController withKeyPath:copyToPasteBoardKeyPath options:nil];
  
  [self.numbersButton setTag:MPPasswordCharactersNumbers];
  [self.upperCaseButton setTag:MPPasswordCharactersUpperCase];
  [self.lowerCaseButton setTag:MPPasswordCharactersLowerCase];
  [self.symbolsButton setTag:MPPasswordCharactersSymbols];
  
  [self updateResponderChain];
  [self _updateSetDefaultButton];
  [self reset];
}

- (void)reset {
  [self _resetCharacters];
  [self _generatePassword:self];
}

#pragma mark -
#pragma mark Events

- (void)flagsChanged:(NSEvent *)theEvent {
  if(!self.allowsEntryDefaults) {
    return;
  }
  BOOL altIsDown = (0 != ([NSEvent modifierFlags] & NSAlternateKeyMask));
  _defaultDomain = altIsDown ? MPEntryDomain : MPGlobalDomain;
  [self _updateSetDefaultButton];
}

#pragma mark -
#pragma mark Actions

- (IBAction)_generatePassword:(id)sender {
  if(_useCustomString) {
    if([[_customCharactersTextField stringValue] length] > 0) {
      self.password = [[_customCharactersTextField stringValue] passwordWithLength:_passwordLength];
    }
  }
  else {
    self.password = [NSString passwordWithCharactersets:_characterFlags length:_passwordLength];
  }
}

- (IBAction)_toggleCharacters:(id)sender {
  [_setDefaultButton setEnabled:YES];
  _characterFlags ^= [sender tag];
  self.useCustomString = NO;
  [self reset];
}

- (IBAction)_usePassword:(id)sender {
  self.generatedPassword = _password;
  if([self.shouldCopyPasswordToPasteboardButton state] == NSOnState) {
    [[MPPasteBoardController defaultController] copyObjects:@[_password]];
  }
  [[self _findCloseTarget] performClose:nil];
}

- (IBAction)_cancel:(id)sender {
  [[self _findCloseTarget] performClose:nil];
}

- (IBAction)_setDefault:(id)sender {
  [[NSUserDefaults standardUserDefaults] setInteger:_passwordLength forKey:kMPSettingsKeyDefaultPasswordLength];
  [[NSUserDefaults standardUserDefaults] setInteger:_characterFlags forKey:kMPSettingsKeyPasswordCharacterFlags];
  [[NSUserDefaults standardUserDefaults] setBool:_useCustomString forKey:kMPSettingsKeyPasswordUseCustomString];
  [[NSUserDefaults standardUserDefaults] setObject:[_customCharactersTextField stringValue] forKey:kMPSettingsKeyPasswordCustomString];
  
  [_setDefaultButton setEnabled:NO];
}

#pragma mark -
#pragma mark Custom Setter

- (void)setPassword:(NSString *)password {
  if(![_password isEqualToString:password]) {
    _password = [password copy];
    NSString *customString = _useCustomString ? [_customCharactersTextField stringValue] : nil;
    self.entropy = [password entropyWhithPossibleCharacterSet:_characterFlags orCustomCharacters:customString];
  }
}

- (void)setUseCustomString:(BOOL)useCustomString {
  if(_useCustomString != useCustomString) {
    [_setDefaultButton setEnabled:YES];
    _useCustomString = useCustomString;
    [self _resetCharacters];
  }
}

- (void)setPasswordLength:(NSUInteger)passwordLength {
  if(_passwordLength != passwordLength) {
    [_setDefaultButton setEnabled:YES];
    _passwordLength = passwordLength;
    [self _generatePassword:nil];
  }
}

#pragma mark -
#pragma mark NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj {
  if([obj object] == self.customCharactersTextField) {
    [_setDefaultButton setEnabled:YES];
    [self _generatePassword:nil];
  }
}

#pragma mark -
#pragma mark Helper

- (void)_updateSetDefaultButton {
  
  switch (_defaultDomain) {
    case MPEntryDomain:
      [self.setDefaultButton setTitle:NSLocalizedString(@"SET_DEFAULT_ENTRY_PASSWORD_RULE", "")];
      break;
      
    case MPGlobalDomain:
    default:
      [self.setDefaultButton setTitle:NSLocalizedString(@"SET_DEFAULT_GENERAL_PASSWORD_RULE", "")];
      break;
  }
}

- (void)_resetCharacters {
  if(_useCustomString) {
    [_customButton setState:NSOnState];
  }
  [_customCharactersTextField setEnabled:_useCustomString];
  [_upperCaseButton setEnabled:!_useCustomString];
  [_lowerCaseButton setEnabled:!_useCustomString];
  [_numbersButton setEnabled:!_useCustomString];
  [_symbolsButton setEnabled:!_useCustomString];
  
  /* Set to defualts, if we got nothing */
  if(_characterFlags == 0) {
    _characterFlags = MPPasswordCharactersAll;
  }
  
  const BOOL userLowercase = ( 0 != (MPPasswordCharactersLowerCase & _characterFlags));
  const BOOL useUppercase = ( 0 != (MPPasswordCharactersUpperCase & _characterFlags) );
  const BOOL useNumbers = ( 0 != (MPPasswordCharactersNumbers & _characterFlags) );
  const BOOL useSymbols = ( 0 != (MPPasswordCharactersSymbols & _characterFlags) );
  
  [_upperCaseButton setState:useUppercase ? NSOnState : NSOffState];
  [_lowerCaseButton setState:userLowercase ? NSOnState : NSOffState];
  [_numbersButton setState:useNumbers ? NSOnState : NSOffState];
  [_symbolsButton setState:useSymbols ? NSOnState : NSOffState];
}

- (id)_findCloseTarget {
  if([self.closeTarget respondsToSelector:@selector(performClose:)]) {
    return self.closeTarget;
  }
  return [NSApp targetForAction:@selector(performClose:)];
}
@end
