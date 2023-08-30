//
//  MPSecurityDatabaseSettingsViewController.m
//  MacPass
//
//  Created by Michael Starke on 18.11.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPSecurityDatabaseSettingsViewController.h"
#import "MPDocument.h"
#import <KeePassKit/KeePassKit.h>


@interface MPSecurityDatabaseSettingsViewController ()

@property (assign) NSInteger argon2dMemory;
@property (assign) NSInteger argon2idMemory;

@property (strong) IBOutlet NSButton *createKeyDerivationParametersButton;
@property (strong) IBOutlet NSPopUpButton *cipherPopupButton;
@property (strong) IBOutlet NSPopUpButton *keyDerivationPopupButton;
@property (strong) IBOutlet NSTabView *keyDerivationSettingsTabView;

/* AES */
@property (strong) IBOutlet NSTextField *aesEncryptionRoundsTextField;
/* Argon2d */
@property (strong) IBOutlet NSTextField *argon2dThreadsTextField;
@property (strong) IBOutlet NSTextField *argon2dIterationsTextField;
@property (strong) IBOutlet NSTextField *argon2dMemoryTextField;
@property (strong) IBOutlet NSStepper *argon2dMemoryStepper;
/* Argon2id */
@property (strong) IBOutlet NSTextField *argon2idThreadsTextField;
@property (strong) IBOutlet NSTextField *argon2idIterationsTextField;
@property (strong) IBOutlet NSTextField *argon2idMemoryTextField;
@property (strong) IBOutlet NSStepper *argon2idMemoryStepper;

@end

@implementation MPSecurityDatabaseSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)_setupSecurityTab {
  
  MPDocument *document = (MPDocument *)self.view.window.windowController.document;
  KPKTree *tree = document.tree;
  KPKMetaData *metaData = tree.metaData;

  /*
   If kdf or cipher is not found, exceptions are thrown.
   This should not happen since we should not be able to load a file with unknown cipher/kdf
   */
  KPKKeyDerivation *keyDerivation = [KPKKeyDerivation keyDerivationWithParameters:metaData.keyDerivationParameters];
  NSUInteger kdfIndex = [self.keyDerivationPopupButton.menu indexOfItemWithRepresentedObject:keyDerivation.uuid];
  [self.keyDerivationPopupButton selectItemAtIndex:kdfIndex];
  [self.keyDerivationSettingsTabView selectTabViewItemWithIdentifier:keyDerivation.uuid];
  
  /* fill defaults for AES */
  KPKAESKeyDerivation *aesKdf = [[KPKAESKeyDerivation alloc] initWithParameters:[KPKAESKeyDerivation defaultParameters]];
  self.aesEncryptionRoundsTextField.integerValue = aesKdf.rounds;
  
  /* fill defaults for Argon2d */
  KPKArgon2DKeyDerivation *argon2dKdf = [[KPKArgon2DKeyDerivation alloc] initWithParameters:[KPKArgon2DKeyDerivation defaultParameters]];
  self.argon2dIterationsTextField.integerValue = argon2dKdf.iterations;
  self.argon2dMemory = argon2dKdf.memory;
  self.argon2dThreadsTextField.integerValue = argon2dKdf.threads;
  
  /* fill defaults for Argon2id */
  KPKArgon2IDKeyDerivation *argon2idKdf = [[KPKArgon2IDKeyDerivation alloc] initWithParameters:[KPKArgon2IDKeyDerivation defaultParameters]];
  self.argon2idIterationsTextField.integerValue = argon2idKdf.iterations;
  self.argon2idMemory = argon2idKdf.memory;
  self.argon2idThreadsTextField.integerValue = argon2idKdf.threads;
  
  if([keyDerivation isMemberOfClass:KPKAESKeyDerivation.class]) {
    /* set to database values */
    KPKAESKeyDerivation *aesKdf = (KPKAESKeyDerivation *)keyDerivation;
    self.aesEncryptionRoundsTextField.integerValue = aesKdf.rounds;
    self.createKeyDerivationParametersButton.enabled = YES;
  }
  else if([keyDerivation isMemberOfClass:KPKArgon2DKeyDerivation.class]) {
    /* set to database value */
    KPKArgon2DKeyDerivation *argon2dKdf = (KPKArgon2DKeyDerivation *)keyDerivation;
    self.argon2dMemory = argon2dKdf.memory;
    self.argon2dThreadsTextField.integerValue = argon2dKdf.threads;
    self.argon2dIterationsTextField.integerValue = argon2dKdf.iterations;
  }
  else if([keyDerivation isMemberOfClass:KPKArgon2IDKeyDerivation.class]) {
    /* set to database value */
    KPKArgon2IDKeyDerivation *argon2idKdf = (KPKArgon2IDKeyDerivation *)keyDerivation;
    self.argon2idMemory = argon2idKdf.memory;
    self.argon2idThreadsTextField.integerValue = argon2idKdf.threads;
    self.argon2idIterationsTextField.integerValue = argon2idKdf.iterations;
  }
  else {
    NSAssert(NO, @"Unkown key derivation");
  }
  
  self.argon2dMemoryStepper.minValue = 8*1024; // 8KB minimum
  self.argon2dMemoryStepper.maxValue = NSIntegerMax;
  self.argon2dMemoryStepper.increment = 1024*1024; // 1 megabytes steps
  [self.argon2dMemoryTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(argon2dMemory)) options:nil];
  [self.argon2dMemoryStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(argon2dMemory)) options:nil];

  self.argon2idMemoryStepper.minValue = 8*1024; // 8KB minimum
  self.argon2idMemoryStepper.maxValue = NSIntegerMax;
  self.argon2idMemoryStepper.increment = 1024*1024; // 1 megabytes steps
  [self.argon2idMemoryTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(argon2idMemory)) options:nil];
  [self.argon2idMemoryStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(argon2idMemory)) options:nil];
  
  NSUInteger cipherIndex = [self.cipherPopupButton.menu indexOfItemWithRepresentedObject:metaData.cipherUUID];
  [self.cipherPopupButton selectItemAtIndex:cipherIndex];
}

@end
