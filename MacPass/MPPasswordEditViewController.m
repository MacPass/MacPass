//
//  MPPasswordEditViewController.m
//  MacPass
//
//  Created by Michael Starke on 29.04.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasswordEditViewController.h"
#import "MPKeyfilePathControlDelegate.h"
#import "MPDocumentWindowController.h"
#import "MPDocument.h"

@interface MPPasswordEditViewController ()
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSPathControl *keyfilePathControl;
@property (strong) MPKeyfilePathControlDelegate *pathControlDelegate;

- (IBAction)_change:(id)sender;
- (IBAction)_cancel:(id)sender;

@end

@implementation MPPasswordEditViewController

- (id)init {
  return [self initWithNibName:@"PasswordEditView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _pathControlDelegate = [[MPKeyfilePathControlDelegate alloc] init];
  }
  return self;
}


- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (void)didLoadView {
  [self.keyfilePathControl setDelegate:self.pathControlDelegate];
}

- (IBAction)_change:(id)sender {
  MPDocument *document = [[self windowController] document];
  if(document) {
    document.key = [self.keyfilePathControl URL];
    NSString *password = [self.passwordTextField stringValue];
    if([password length] > 0) {
      document.password = password;
    }
    else {
      document.password = nil;
    }
  }
  id mainWindowController = [[[self view] window] windowController];
  [mainWindowController showEntries];
}

- (IBAction)_cancel:(id)sender {
  id mainWindowController = [[[self view] window] windowController];
  [mainWindowController showEntries];
}
@end
