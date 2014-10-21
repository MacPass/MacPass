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

#import "KPKEntry.h"

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

#define MIN_PASSWORD_LENGTH 1
#define MAX_PASSWORD_LENGTH 256

@interface MPPasswordCreatorViewController ()

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
@property (weak) IBOutlet NSButton *useEntryDefaultsButton;

@property (nonatomic, copy) NSString *customString;
@property (nonatomic, assign) BOOL useCustomString;
@property (nonatomic, assign) NSUInteger passwordLength;
@property (nonatomic, assign) CGFloat entropy;

@property (nonatomic, assign) BOOL useEntryDefaults;
@property (nonatomic, assign) MPPasswordCharacterFlags characterFlags;

@end

@implementation MPPasswordCreatorViewController

- (NSString *)nibName {
  return @"PasswordCreatorView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _password = @"";
    _entropy = 0.0;
    _useEntryDefaults = NO;
    _allowsEntryDefaults = NO;
    [self _setupDefaults];
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
  
  if(self.allowsEntryDefaults) {
    [self.useEntryDefaultsButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(useEntryDefaults)) options:nil];
  }
  else {
    [self.useEntryDefaultsButton setEnabled:self.allowsEntryDefaults];
  }
  
  [self.numbersButton setTag:MPPasswordCharactersNumbers];
  [self.upperCaseButton setTag:MPPasswordCharactersUpperCase];
  [self.lowerCaseButton setTag:MPPasswordCharactersLowerCase];
  [self.symbolsButton setTag:MPPasswordCharactersSymbols];
  
  [self updateResponderChain];
  [self reset];
}

- (void)reset {
  [self _resetCharacters];
  [self _generatePassword:self];
}

#pragma mark -
#pragma mark Actions

- (IBAction)_generatePassword:(id)sender {
  if(self.useCustomString) {
    if([[self.customCharactersTextField stringValue] length] > 0) {
      self.password = [[self.customCharactersTextField stringValue] passwordWithLength:self.passwordLength];
    }
  }
  else {
    self.password = [NSString passwordWithCharactersets:self.characterFlags length:self.passwordLength];
  }
}

- (IBAction)_toggleCharacters:(id)sender {
  [self.setDefaultButton setEnabled:YES];
  self.characterFlags ^= [sender tag];
  self.useCustomString = NO;
  [self reset];
}

- (IBAction)_usePassword:(id)sender {
  self.generatedPassword = self.password;
  if([self.shouldCopyPasswordToPasteboardButton state] == NSOnState) {
    [[MPPasteBoardController defaultController] copyObjects:@[self.password]];
  }
  [[self _findCloseTarget] performClose:nil];
}

- (IBAction)_cancel:(id)sender {
  [[self _findCloseTarget] performClose:nil];
}

- (IBAction)_setDefault:(id)sender {
  if(self.useEntryDefaults) {
    NSMutableDictionary *entryDefaults = [[self _currentEntryDefaults] mutableCopy];
    if(!entryDefaults) {
      entryDefaults = [[NSMutableDictionary alloc] initWithCapacity:4]; // we will only add one enty to new settings
    }
    entryDefaults[kMPSettingsKeyDefaultPasswordLength] = @(self.passwordLength);
    entryDefaults[kMPSettingsKeyPasswordCharacterFlags] = @(self.characterFlags);
    entryDefaults[kMPSettingsKeyPasswordUseCustomString] = @(self.useCustomString);
    entryDefaults[kMPSettingsKeyPasswordCustomString] = [self.customCharactersTextField stringValue];
    NSMutableDictionary *availableDefaults = [[self _availableEntryDefaults] mutableCopy];
    if(!availableDefaults) {
      availableDefaults = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    availableDefaults[self.entry.uuid] = entryDefaults;
  }
  else {
    [[NSUserDefaults standardUserDefaults] setInteger:self.passwordLength forKey:kMPSettingsKeyDefaultPasswordLength];
    [[NSUserDefaults standardUserDefaults] setInteger:self.characterFlags forKey:kMPSettingsKeyPasswordCharacterFlags];
    [[NSUserDefaults standardUserDefaults] setBool:self.useCustomString forKey:kMPSettingsKeyPasswordUseCustomString];
    [[NSUserDefaults standardUserDefaults] setObject:[self.customCharactersTextField stringValue] forKey:kMPSettingsKeyPasswordCustomString];
  }
  [self.setDefaultButton setEnabled:NO];
}

#pragma mark -
#pragma mark Custom Setter
- (void)setUseEntryDefaults:(BOOL)useEntryDefaults {
  if(self.useEntryDefaults != useEntryDefaults) {
    _useEntryDefaults = useEntryDefaults;
    [self _setupDefaults];
    [self reset];
  }
}

- (void)setEntry:(KPKEntry *)entry {
  if(_entry != entry) {
    _entry = entry;
    [self _setupDefaults];
    [self reset];
  }
}

- (void)setPassword:(NSString *)password {
  if(![_password isEqualToString:password]) {
    _password = [password copy];
    NSString *customString = self.useCustomString ? [self.customCharactersTextField stringValue] : nil;
    self.entropy = [password entropyWhithPossibleCharacterSet:self.characterFlags orCustomCharacters:customString];
  }
}

- (void)setUseCustomString:(BOOL)useCustomString {
  if(self.useCustomString != useCustomString) {
    [self.setDefaultButton setEnabled:YES];
    _useCustomString = useCustomString;
    [self _resetCharacters];
  }
}

- (void)setPasswordLength:(NSUInteger)passwordLength {
  if(self.passwordLength != passwordLength) {
    [self.setDefaultButton setEnabled:YES];
    _passwordLength = passwordLength;
    [self _generatePassword:nil];
  }
}

#pragma mark -
#pragma mark NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj {
  if([obj object] == self.customCharactersTextField) {
    [self.setDefaultButton setEnabled:YES];
    [self _generatePassword:nil];
  }
}

#pragma mark -
#pragma mark Helper
- (NSDictionary *)_availableEntryDefaults {
  return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMPSettingsKeyPasswordDefaultsForEntry];
}

- (NSDictionary *)_currentEntryDefaults {
  if(self.entry) {
    return [self _availableEntryDefaults][self.entry.uuid];
  }
  return nil;
}

- (void)_setupDefaults {
  NSDictionary *entryDefaults = [self _currentEntryDefaults];
  if(entryDefaults) {
    self.passwordLength = [entryDefaults[kMPSettingsKeyDefaultPasswordLength] integerValue];
    self.characterFlags = [entryDefaults[kMPSettingsKeyPasswordCharacterFlags] integerValue];
    self.useCustomString = [entryDefaults[kMPSettingsKeyPasswordUseCustomString] boolValue];
    self.customString = [entryDefaults[kMPSettingsKeyPasswordCustomString] stringValue];
  }
  else {
    self.passwordLength = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDefaultPasswordLength];
    self.characterFlags = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyPasswordCharacterFlags];
    self.useCustomString = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyPasswordUseCustomString];
    self.customString = [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyPasswordCustomString];
  }
}

- (void)_resetCharacters {
  if(self.useCustomString) {
    [self.customButton setState:NSOnState];
  }
  [self.customCharactersTextField setEnabled:_useCustomString];
  [self.upperCaseButton setEnabled:!_useCustomString];
  [self.lowerCaseButton setEnabled:!_useCustomString];
  [self.numbersButton setEnabled:!_useCustomString];
  [self.symbolsButton setEnabled:!_useCustomString];
  
  /* Set to defaults, if we got nothing */
  if(self.characterFlags == 0) {
    self.characterFlags = MPPasswordCharactersAll;
  }
  
  const BOOL userLowercase = ( 0 != (MPPasswordCharactersLowerCase & self.characterFlags));
  const BOOL useUppercase = ( 0 != (MPPasswordCharactersUpperCase & self.characterFlags) );
  const BOOL useNumbers = ( 0 != (MPPasswordCharactersNumbers & self.characterFlags) );
  const BOOL useSymbols = ( 0 != (MPPasswordCharactersSymbols & self.characterFlags) );
  
  [self.upperCaseButton setState:useUppercase ? NSOnState : NSOffState];
  [self.lowerCaseButton setState:userLowercase ? NSOnState : NSOffState];
  [self.numbersButton setState:useNumbers ? NSOnState : NSOffState];
  [self.symbolsButton setState:useSymbols ? NSOnState : NSOffState];
}

- (id)_findCloseTarget {
  if([self.closeTarget respondsToSelector:@selector(performClose:)]) {
    return self.closeTarget;
  }
  return [NSApp targetForAction:@selector(performClose:)];
}
@end
