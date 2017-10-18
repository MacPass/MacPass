//
//  PasswordCreatorView.m
//  MacPass
//
//  Created by Michael Starke on 31.03.13.
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

#import "MPPasswordCreatorViewController.h"
#import "MPPasteBoardController.h"
#import "NSString+MPPasswordCreation.h"
#import "MPUniqueCharactersFormatter.h"
#import "MPSettingsHelper.h"
#import "MPDocument.h"
#import "MPModelChangeObserving.h"

#import "MPFlagsHelper.h"

#import "KeePassKit/KeePassKit.h"

/*
 
 0 - 20 Terrible
 21 - 31 Weak
 32 - 55 Good
 56 - 85 Excellent
 85 - Fantastic
 
 Scale 0-90
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
  self.setDefaultButton.enabled = NO;
  [self _updateSetDefaultsButton:NO];
  
  self.passwordLengthSlider.minValue = MIN_PASSWORD_LENGTH;
  self.passwordLengthSlider.maxValue = MAX_PASSWORD_LENGTH;
  self.passwordLengthSlider.continuous = YES;
  
  self.customCharactersTextField.stringValue = self.customString;
  
  /* Value Transformer */
  id formatter = [[MPUniqueCharactersFormatter alloc] init];
  self.customCharactersTextField.formatter = formatter;
  
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
  
  self.numbersButton.tag = MPPasswordCharactersNumbers;
  self.upperCaseButton.tag = MPPasswordCharactersUpperCase;
  self.lowerCaseButton.tag = MPPasswordCharactersLowerCase;
  self.symbolsButton.tag = MPPasswordCharactersSymbols;
  
  [self reset];
}

- (void)reset {
  [self _resetCharacters];
  [self _generatePassword:self];
}

#pragma mark -
#pragma mark Key Events

- (void)flagsChanged:(NSEvent *)theEvent {
  if(!self.allowsEntryDefaults || (nil == [self _currentEntryDefaults])) {
    return; // We aren't using entry so just leave;
  }
  BOOL deleteEntryDefaults = MPIsFlagSetInOptions(NSAlternateKeyMask, [NSEvent modifierFlags]);
  [self _updateSetDefaultsButton:deleteEntryDefaults];
}

#pragma mark -
#pragma mark Actions

- (IBAction)_generatePassword:(id)sender {
  self.password = [NSString passwordWithCharactersets:self.characterFlags
                                 withCustomCharacters:self._customCharacters
                                               length:self.passwordLength];
}

- (NSString*)_customCharacters{
  if(self.useCustomString && [[self.customCharactersTextField stringValue] length] > 0) {
      return self.customCharactersTextField.stringValue;
    }
    else{
      return @"";
    }
  
}

- (IBAction)_toggleCharacters:(id)sender {
  self.setDefaultButton.enabled = YES;
  self.characterFlags ^= [sender tag];
  [self reset];
}

- (IBAction)_usePassword:(id)sender {
  if(self.shouldCopyPasswordToPasteboardButton.state == NSOnState) {
    [[MPPasteBoardController defaultController] copyObjects:@[self.password]];
  }
  KPKEntry *entry = self.representedObject;
  if(entry && self.password.length > 0) {
    [self.observer willChangeModelProperty];
    entry.password = self.password;
    [self.observer didChangeModelProperty];
  }
  [self.view.window performClose:sender];
}

- (IBAction)_cancel:(id)sender {
  [self.view.window performClose:sender];
}

- (IBAction)_setDefault:(id)sender {
  if(self.useEntryDefaults && self.representedObject) {
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
    availableDefaults[[self.representedObject uuid].UUIDString] = entryDefaults;
    [[NSUserDefaults standardUserDefaults] setObject:availableDefaults forKey:kMPSettingsKeyPasswordDefaultsForEntry];
  }
  else if(!self.useEntryDefaults) {
    [[NSUserDefaults standardUserDefaults] setInteger:self.passwordLength forKey:kMPSettingsKeyDefaultPasswordLength];
    [[NSUserDefaults standardUserDefaults] setInteger:self.characterFlags forKey:kMPSettingsKeyPasswordCharacterFlags];
    [[NSUserDefaults standardUserDefaults] setBool:self.useCustomString forKey:kMPSettingsKeyPasswordUseCustomString];
    [[NSUserDefaults standardUserDefaults] setObject:[self.customCharactersTextField stringValue] forKey:kMPSettingsKeyPasswordCustomString];
  }
  else {
    NSLog(@"Cannot set password generator defaults. Inconsistent state. Aborting.");
  }
  self.setDefaultButton.enabled = NO;
}

- (IBAction)_resetEntryDefaults:(id)sender {
  NSMutableDictionary *entryDefaults = [[self _currentEntryDefaults] mutableCopy];
  if(!entryDefaults) {
    return; // We have no defaults, hence nothing to delete
  }
  NSMutableDictionary *availableDefaults = [[self _availableEntryDefaults] mutableCopy];
  NSAssert(availableDefaults, @"Password generator defaults for should be present!");
  [availableDefaults removeObjectForKey:[self.representedObject uuid].UUIDString];
  [[NSUserDefaults standardUserDefaults] setObject:availableDefaults forKey:kMPSettingsKeyPasswordDefaultsForEntry];
  self.useEntryDefaults = NO; /* Resetting the UI and Defaults is handled via the setter */
  [self _updateSetDefaultsButton:NO];
}

#pragma mark -
#pragma mark Custom Setter

- (void)setUseEntryDefaults:(BOOL)useEntryDefaults {
  if(self.useEntryDefaults != useEntryDefaults) {
    _useEntryDefaults = useEntryDefaults;
    self.setDefaultButton.enabled = YES;
    [self _setupDefaults];
    [self reset];
  }
}

- (void)setRepresentedObject:(id)representedObject {
  if(self.representedObject != representedObject) {
    self.useEntryDefaults = [self _hasValidDefaultsForCurrentEntry];
  }
  [super setRepresentedObject:representedObject];
}

- (void)setPassword:(NSString *)password {
  if(![_password isEqualToString:password]) {
    _password = [password copy];
    NSString *customString = self.useCustomString ? self.customCharactersTextField.stringValue : nil;
    self.entropy = [password entropyWhithPossibleCharacterSet:self.characterFlags orCustomCharacters:customString];
  }
}

- (void)setUseCustomString:(BOOL)useCustomString {
  if(self.useCustomString != useCustomString) {
    self.setDefaultButton.enabled = YES;
    _useCustomString = useCustomString;
    [self _resetCharacters];
  }
}

- (void)setPasswordLength:(NSUInteger)passwordLength {
  if(self.passwordLength != passwordLength) {
    self.setDefaultButton.enabled = YES;
    _passwordLength = passwordLength;
    [self _generatePassword:nil];
  }
}

#pragma mark -
#pragma mark NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj {
  if([obj object] == self.customCharactersTextField) {
    self.setDefaultButton.enabled = YES;
    [self _generatePassword:nil];
  }
}

#pragma mark -
#pragma mark Helper
- (void)_updateSetDefaultsButton:(BOOL)shouldDeleteEntryDefaults {
  if(shouldDeleteEntryDefaults) {
    self.setDefaultButton.title = NSLocalizedString(@"PASSWORD_GENERATOR_RESET_ENTRY_DEFAULTS", "");
    self.setDefaultButton.enabled = YES;
    self.setDefaultButton.action = @selector(_resetEntryDefaults:);
  }
  else {
    self.setDefaultButton.title = NSLocalizedString(@"PASSWORD_GENERATOR_SET_DEFAULTS", "");
    self.setDefaultButton.action = @selector(_setDefault:);
  }
}

- (NSDictionary *)_availableEntryDefaults {
  return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMPSettingsKeyPasswordDefaultsForEntry];
}

- (NSDictionary *)_currentEntryDefaults {
  if(self.representedObject) {
    NSAssert([self.representedObject isKindOfClass:[KPKEntry class]], @"Only KPKEntry as represented object supported!");
    return [self _availableEntryDefaults][[self.representedObject uuid].UUIDString];
  }
  return nil;
}

- (void)_setupDefaults {
  NSDictionary *entryDefaults = [self _currentEntryDefaults];
  if(entryDefaults && self.useEntryDefaults) {
    self.passwordLength = [entryDefaults[kMPSettingsKeyDefaultPasswordLength] integerValue];
    self.characterFlags = [entryDefaults[kMPSettingsKeyPasswordCharacterFlags] integerValue];
    self.useCustomString = [entryDefaults[kMPSettingsKeyPasswordUseCustomString] boolValue];
    self.customString = entryDefaults[kMPSettingsKeyPasswordCustomString];
  }
  else {
    self.passwordLength = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDefaultPasswordLength];
    self.characterFlags = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyPasswordCharacterFlags];
    self.useCustomString = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyPasswordUseCustomString];
    self.customString = [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyPasswordCustomString];
  }
}

- (BOOL)_hasValidDefaultsForCurrentEntry {
  return (nil != [self _currentEntryDefaults]);
}

- (void)_resetCharacters {
  if(self.useCustomString) {
    self.customButton.state = NSOnState;
  }
  self.customCharactersTextField.enabled = self.useCustomString;
  
  /* Set to defaults, if we got nothing */
  if(self.characterFlags == 0 && !self.useCustomString) {
    self.characterFlags = MPPasswordCharactersAll;
  }
  
  const BOOL userLowercase = (0 != (MPPasswordCharactersLowerCase & self.characterFlags));
  const BOOL useUppercase = (0 != (MPPasswordCharactersUpperCase & self.characterFlags));
  const BOOL useNumbers = (0 != (MPPasswordCharactersNumbers & self.characterFlags));
  const BOOL useSymbols = (0 != (MPPasswordCharactersSymbols & self.characterFlags));
  
  self.upperCaseButton.state = (useUppercase ? NSOnState : NSOffState);
  self.lowerCaseButton.state = (userLowercase ? NSOnState : NSOffState);
  self.numbersButton.state = (useNumbers ? NSOnState : NSOffState);
  self.symbolsButton.state = (useSymbols ? NSOnState : NSOffState);
}
@end
