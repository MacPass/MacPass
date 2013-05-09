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
#import "MPKeyfilePathControlDelegate.h"

@interface MPPasswordInputController ()

@property (assign) IBOutlet NSSecureTextField *passwordTextField;
@property (assign) IBOutlet NSPathControl *keyPathControl;
@property (retain) MPKeyfilePathControlDelegate *pathControlDelegate;
@property (assign) IBOutlet NSImageView *errorImageView;
@property (assign) IBOutlet NSTextField *errorInfoTextField;

- (IBAction)_decrypt:(id)sender;
- (void)_showError;
- (void)_reset;

@end

@implementation MPPasswordInputController

- (id)init {
  return [[MPPasswordInputController alloc] initWithNibName:@"PasswordInputView" bundle:nil];
}

- (void)dealloc {
  [_pathControlDelegate release];
  [super dealloc];
}

- (void)didLoadView {
  [self.keyPathControl setDelegate:self.pathControlDelegate];
  [self.errorImageView setImage:[NSImage imageNamed:NSImageNameCaution]];
  [self _reset];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.passwordTextField;
}

- (IBAction)_decrypt:(id)sender {
  MPDocumentWindowController *windowController = (MPDocumentWindowController *)[[[self view] window] windowController];
  MPDocument *document = [windowController document];
  if(document) {
    BOOL isOk = [document decryptWithPassword:[self.passwordTextField stringValue] keyFileURL:[self.keyPathControl URL]];
    if(!isOk) {
      [self _showError];
    }
  }
  [self _reset];
  [windowController showEntries];
}

- (void)_reset {
  [self.passwordTextField setStringValue:@""];
  [self.keyPathControl setURL:nil];
  [self.errorInfoTextField setHidden:YES];
  [self.errorImageView setHidden:YES];
}

- (void)_showError {
  [self.errorImageView setHidden:NO];
  [self.errorInfoTextField setHidden:NO];
}
@end
