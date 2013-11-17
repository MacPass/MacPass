//
//  MPPasswordInputController.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordInputController.h"
#import "MPDocumentWindowController.h"
#import "MPDocument.h"
#import "MPSettingsHelper.h"
#import "MPKeyfilePathControlDelegate.h"

#import "HNHRoundedSecureTextField.h"
#import "NSError+Messages.h"

@interface MPPasswordInputController ()

@property (weak) IBOutlet HNHRoundedSecureTextField *passwordTextField;
@property (weak) IBOutlet NSPathControl *keyPathControl;
@property (strong) MPKeyfilePathControlDelegate *pathControlDelegate;
@property (weak) IBOutlet NSImageView *errorImageView;
@property (weak) IBOutlet NSTextField *errorInfoTextField;
@property (weak) IBOutlet NSButton *togglePasswordButton;

@property (assign) BOOL showPassword;

@end

@implementation MPPasswordInputController

- (id)init {
  self = [self initWithNibName:@"PasswordInputView" bundle:nil];
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectKeyURL) name:MPDocumentDidChangeStoredKeyFilesSettings object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didLoadView {
  [self.keyPathControl setDelegate:self.pathControlDelegate];
  [self.errorImageView setImage:[NSImage imageNamed:NSImageNameCaution]];
  [self.passwordTextField bind:@"showPassword" toObject:self withKeyPath:@"showPassword" options:nil];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:@"showPassword" options:nil];
  [self _reset];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (void)requestPassword {
  // show Warnign if read-only mode!
  [self _reset];
}

#pragma mark -
#pragma mark Private
- (IBAction)_decrypt:(id)sender {
  MPDocument *document = [[self windowController] document];
  if(document) {
    NSError *error = nil;
    if(![document unlockWithPassword:[self.passwordTextField stringValue]
                          keyFileURL:[self.keyPathControl URL]
                               error:&error]) {
      [self _showError:error];
    }
  }
}

- (IBAction)resetKeyFile:(id)sender {
  [self _selectKeyURL];
}

- (void)_reset {
  self.showPassword = NO;
  [self.passwordTextField setStringValue:@""];
  [self.errorInfoTextField setHidden:YES];
  [self.errorImageView setHidden:YES];
  [self resetKeyFile:nil];
}

- (void)_selectKeyURL {
  MPDocument *document = [[self windowController] document];
  [self.keyPathControl setURL:document.suggestedKeyURL];
}

- (void)_showError:(NSError *)error {
  if(error) {
    NSString *errorMessage = [error descriptionForErrorCode];
    [self.errorInfoTextField setStringValue:errorMessage];
  }
  [self.errorImageView setHidden:NO];
  [self.errorInfoTextField setHidden:NO];
}

@end
