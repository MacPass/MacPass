//
//  PasswordCreatorView.m
//  MacPass
//
//  Created by Michael Starke on 31.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordCreatorViewController.h"

#define MIN_PASSWORD_LENGTH 1
#define MAX_PASSWORD_LENGTH 64

@interface MPPasswordCreatorViewController ()
@property (assign) IBOutlet NSTextField *passwordTextField;
@property (assign) IBOutlet NSTextField *passwordLengthTextField;
@property (assign) IBOutlet NSTextField *customCharactersTextField;
@property (assign) IBOutlet NSSlider *passwordLengthSlider;

@property (assign) NSUInteger passwordLength;

- (IBAction)_create:(id)sender;
- (IBAction)_toggleCharacters:(id)sender;

@end

@implementation MPPasswordCreatorViewController

- (id)init {
  self = [super initWithNibName:@"PasswordCreatorView" bundle:nil];
  if (self) {
    _passwordLength = 12;
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
}

- (IBAction)_create:(id)sender {
  
}

- (IBAction)_toggleCharacters:(id)sender {
}
@end
