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

@property (nonatomic, assign) BOOL shouldSelectKeyFile;
@property (assign) BOOL showPassword;

- (IBAction)_decrypt:(id)sender;
- (IBAction)_clearKey:(id)sender;

@end

@implementation MPPasswordInputController

- (id)init {
  self = [self initWithNibName:@"PasswordInputView" bundle:nil];
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _showLastUsedKeyFile = NO;
    _shouldSelectKeyFile = NO;
  }
  return self;
}

- (void)didLoadView {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  [self bind:@"shouldSelectKeyFile" toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyRememberKeyFilesForDatabases ] options:nil];

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
  if(self.showLastUsedKeyFile) {
    [self _selectRecentKeyFile];
  }
}

#pragma mark Properties
- (void)setShouldSelectKeyFile:(BOOL)shouldSelectKeyFile {
  if(_shouldSelectKeyFile != shouldSelectKeyFile) {
    _shouldSelectKeyFile = shouldSelectKeyFile;
  }
}

#pragma mark -
#pragma mark Private
- (IBAction)_decrypt:(id)sender {
  id windowController = [[[self view] window] windowController];
  MPDocument *document = [windowController document];
  if(document) {
    NSError *error = nil;
    if(![document unlockWithPassword:[self.passwordTextField stringValue]
                          keyFileURL:[self.keyPathControl URL]
                               error:&error]) {
      [self _showError:error];
    }
  }
}

- (IBAction)_clearKey:(id)sender {
  [self.keyPathControl setURL:nil];
}

- (void)_reset {
  self.showPassword = NO;
  [self.passwordTextField setStringValue:@""];
  [self.keyPathControl setURL:nil];
  [self.errorInfoTextField setHidden:YES];
  [self.errorImageView setHidden:YES];
}

- (void)_selectRecentKeyFile {
  if(!self.shouldSelectKeyFile) {
    [self.keyPathControl setURL:nil];
    return; // If we aren't supposed to preselect paths, clear them!
  }

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
