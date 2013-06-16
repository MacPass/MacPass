//
//  PasswordCreatorView.m
//  MacPass
//
//  Created by Michael Starke on 31.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordCreatorViewController.h"
#import "NSString+MPPasswordCreation.h"

#define MIN_PASSWORD_LENGTH 1
#define MAX_PASSWORD_LENGTH 64


@interface MPPasswordCreatorViewController () {
  MPPasswordCharacterFlags _characterFlags;
}
@property (assign) IBOutlet NSTextField *passwordTextField;
@property (assign) IBOutlet NSTextField *passwordLengthTextField;
@property (assign) IBOutlet NSTextField *customCharactersTextField;
@property (assign) IBOutlet NSSlider *passwordLengthSlider;
@property (assign) IBOutlet NSButton *addPasswordToPasteboardButton;
@property (assign) IBOutlet NSButton *upperCaseButton;
@property (assign) IBOutlet NSButton *lowerCaseButton;
@property (assign) IBOutlet NSButton *numbersButton;
@property (assign) IBOutlet NSButton *symbolsButton;
@property (assign) IBOutlet NSButton *customButton;

@property (assign, nonatomic) BOOL useCustomString;
@property (assign, nonatomic) NSUInteger passwordLength;

- (IBAction)_generatePassword:(id)sender;
- (IBAction)_toggleCharacters:(id)sender;
- (IBAction)_usePassword:(id)sender;

@end

@implementation MPPasswordCreatorViewController

- (id)init {
  self = [super initWithNibName:@"PasswordCreatorView" bundle:nil];
  if (self) {
    _password = @"";
    _passwordLength = 12;
    _characterFlags = MPPasswordCharactersAll;
    _useCustomString = NO;
  }
  return self;
}

- (void)didLoadView {
  [self.passwordLengthSlider setMinValue:MIN_PASSWORD_LENGTH];
  [self.passwordLengthSlider setMaxValue:MAX_PASSWORD_LENGTH];
  [self.passwordLengthSlider setContinuous:YES];
  /* Value Transformer */
  [self.passwordLengthSlider bind:NSValueBinding toObject:self withKeyPath:@"passwordLength" options:nil];
  [self.passwordLengthTextField bind:NSValueBinding toObject:self withKeyPath:@"passwordLength" options:nil];
  [self.passwordTextField bind:NSValueBinding toObject:self withKeyPath:@"password" options:nil];
  
  [_customButton bind:NSValueBinding toObject:self withKeyPath:@"useCustomString" options:nil];
  [_numbersButton setTag:MPPasswordCharactersNumbers];
  [_upperCaseButton setTag:MPPasswordCharactersUpperCase];
  [_lowerCaseButton setTag:MPPasswordCharactersLowerCase];
  [_symbolsButton setTag:MPPasswordCharactersSymbols];
  
  [self _resetCharacters];
}

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
  _characterFlags ^= [sender tag];
  self.useCustomString = NO;
  [self _resetCharacters];
}

- (IBAction)_usePassword:(id)sender {
}

- (void)setUseCustomString:(BOOL)useCustomString {
  if(_useCustomString != useCustomString) {
    _useCustomString = useCustomString;
    [self _resetCharacters];
  }
}

- (void)setPasswordLength:(NSUInteger)passwordLength {
  if(_passwordLength != passwordLength) {
    _passwordLength = passwordLength;
    [self _generatePassword:nil];
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
@end
