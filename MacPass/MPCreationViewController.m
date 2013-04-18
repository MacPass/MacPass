//
//  MPCreationViewController.m
//  MacPass
//
//  Created by Nathaniel Madura on 18/04/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPCreationViewController.h"
#import "MPKeyfilePathControlDelegate.h"
#import "MPDatabaseController.h"
#import "MPDatabaseDocument.h"

@interface MPCreationViewController ()

@property (assign) IBOutlet NSSecureTextField *passwordTextField;
@property (assign) IBOutlet NSSecureTextField *validatePasswordTextField;
@property (assign) IBOutlet NSPathControl *keyPathControl;
@property (retain) MPKeyfilePathControlDelegate *pathControlDelegate;
@property (assign) IBOutlet NSTextField *errorInfoTextField;

- (IBAction)_new:(id)sender;
- (void)_showError;
- (void)_reset;

@end

@implementation MPCreationViewController

- (id)init {
  return [[MPCreationViewController alloc] initWithNibName:@"CreationView" bundle:nil];
}

- (void)dealloc {
  [_fileURL release];
  [_pathControlDelegate release];
  [super dealloc];
}

- (void)didLoadView {
  [self.keyPathControl setDelegate:self.pathControlDelegate];
  [self _reset];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (IBAction)_new:(id)sender {
  NSString *password = self.passwordTextField.stringValue;
  NSURL *keyfile = [self.keyPathControl URL];
  if ([password compare:self.validatePasswordTextField.stringValue] != NSOrderedSame)
  {
    [self.errorInfoTextField setStringValue:@"Passwords do not match"];
    [self.errorInfoTextField setHidden:NO];
  }
  [self _reset];
  
  [[MPDatabaseController defaultController] newDatabaseAtURL:self.fileURL
                                             databaseVersion:MPDatabaseVersion4
                                                    password:password
                                                     keyfile:keyfile];
}

- (void)_reset {
  [self.passwordTextField setStringValue:@""];
  [self.validatePasswordTextField setStringValue:@""];
  [self.keyPathControl setURL:nil];
  [self.errorInfoTextField setHidden:YES];
}

- (void)_showError {
  [self.errorInfoTextField setHidden:NO];
}

@end
