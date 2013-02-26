//
//  MPPasswordInputController.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordInputController.h"
#import "MPDatabaseController.h"

@interface MPPasswordInputController ()

@property (assign) IBOutlet NSSecureTextField *passwordTextField;

- (IBAction)_selectKeyFile:(id)sender;
- (IBAction)_open:(id)sender;
- (void)_showError;

@end

@implementation MPPasswordInputController

- (id)init {
  return [[MPPasswordInputController alloc] initWithNibName:@"PasswordInputView" bundle:nil];
}

- (void)dealloc {
  self.fileURL = nil;
  [super dealloc];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (IBAction)_selectKeyFile:(id)sender {

}

- (IBAction)_open:(id)sender {
  NSString *password = [self.passwordTextField stringValue];
  [self.passwordTextField setStringValue:@""];
  MPDatabaseDocument *document = [[MPDatabaseController defaultController] openDatabase:self.fileURL
                                                                               password:password
                                                                                keyfile:nil];
  if(!document) {
    [self _showError];
  }
}

- (void)_showError {
  NSLog(@"Something went wrong");
}
@end
