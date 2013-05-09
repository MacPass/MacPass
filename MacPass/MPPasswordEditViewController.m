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
@property (assign) IBOutlet NSSecureTextField *passwordTextField;
@property (assign) IBOutlet NSPathControl *keyfilePathControl;
@property (retain) MPKeyfilePathControlDelegate *pathControlDelegate;

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

- (void)dealloc {
  [self.pathControlDelegate release];
  [super dealloc];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (void)didLoadView {
  [self.keyfilePathControl setDelegate:self.pathControlDelegate];
}

- (IBAction)_change:(id)sender {
  MPDocument *document = [[NSDocumentController sharedDocumentController] documentForWindow:[[self view] window]];
  if(document) {
    document.key = [self.keyfilePathControl URL];
    document.password = [self.passwordTextField stringValue];
  }
  MPDocumentWindowController *mainWindowController = (MPDocumentWindowController *)[[[self view] window] windowController];
  [mainWindowController showEntries];
}

- (IBAction)_cancel:(id)sender {
  MPDocumentWindowController *mainWindowController = (MPDocumentWindowController *)[[[self view] window] windowController];
  [mainWindowController showEntries];
}
@end
