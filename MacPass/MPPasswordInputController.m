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

@property (nonatomic, assign) BOOL shouldRememberKeyURL;
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
    _shouldRememberKeyURL = NO;
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    [self bind:@"shouldRememberKeyURL" toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyRememberKeyFilesForDatabases ] options:nil];
    
  }
  return self;
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
  if(self.showLastUsedKeyFile) {
    [self _selectRecentKeyFile];
  }
}

#pragma mark Properties
- (void)setShouldRememberKeyURL:(BOOL)shouldSelectKeyFile {
  if(_shouldRememberKeyURL != shouldSelectKeyFile) {
    _shouldRememberKeyURL = shouldSelectKeyFile;
    if(!self.shouldRememberKeyURL) {
      /* Remove any old settings to clean them up */
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMPSettingsKeyRememeberdKeysForDatabases];
    }
  }
}

#pragma mark -
#pragma mark Private
- (IBAction)_decrypt:(id)sender {
  MPDocument *document = [[self windowController] document];
  if(document) {
    NSError *error = nil;
    NSURL *keyURL = [self.keyPathControl URL];
    if([document unlockWithPassword:[self.passwordTextField stringValue] keyFileURL:keyURL error:&error]) {
      [self _setUsedKeyURL:keyURL forDocument:document];
    }
    else {
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
  if(!self.shouldRememberKeyURL) {
    [self.keyPathControl setURL:nil];
    return; // If we aren't supposed to preselect paths, clear them!
  }
  NSDictionary *keysForFiles = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMPSettingsKeyRememeberdKeysForDatabases];
  MPDocument *document = [[self windowController] document];
  if(document) {
    NSString *keyPath = keysForFiles[[[document fileURL] path]];
    NSURL *keyURL = keyPath != nil ? [NSURL fileURLWithPath:keyPath] : nil;
    [self.keyPathControl setURL:keyURL];
  }
}

- (void)_setUsedKeyURL:(NSURL *)keyURL forDocument:(NSDocument *)document {
  if(!self.shouldRememberKeyURL) {
    return;
  }
  NSMutableDictionary *keysForFiles = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kMPSettingsKeyRememeberdKeysForDatabases] mutableCopy];
  if(nil == keysForFiles) {
    keysForFiles = [[NSMutableDictionary alloc] initWithCapacity:1];
  }
  NSLog(@"remembering keyfile %@ for document %@ at URL %@", keyURL, [document displayName], [document fileURL]);
  keysForFiles[[[document fileURL] path]] = [keyURL path];
  [[NSUserDefaults standardUserDefaults] setObject:keysForFiles forKey:kMPSettingsKeyRememeberdKeysForDatabases];
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
