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

- (IBAction)selectKeyFile:(id)sender;
- (IBAction)open:(id)sender;

@end

@implementation MPPasswordInputController

- (id)init {
  return [[MPPasswordInputController alloc] initWithNibName:@"PasswordView" bundle:nil];
}

- (NSResponder *)reconmendetFirstResponder {
  return nil;
}


- (IBAction)selectKeyFile:(id)sender {

}

- (IBAction)open:(id)sender {
    NSString *password = [self.passwordTextField stringValue];
    [[MPDatabaseController defaultController] openDatabase:self.openFile password:password keyfile:nil];
  }
}
@end
