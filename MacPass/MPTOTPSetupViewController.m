//
//  MPTOTPSetupViewController.m
//  MacPass
//
//  Created by Michael Starke on 10.12.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPTOTPSetupViewController.h"
#import "NSImage+MPQRCode.h"
#import <KeePassKit/KeePassKit.h>

@interface MPTOTPSetupViewController ()
@property (strong) IBOutlet NSTextField *urlTextField;
@property (strong) IBOutlet NSTextField *secretTextField;
@property (strong) IBOutlet NSPopUpButton *algorithmPopUpButton;
@property (strong) IBOutlet NSTextField *timeStepTextField;
@property (strong) IBOutlet NSStepper *timeStepStepper;
@property (strong) IBOutlet NSPopUpButton *digitCountPopUpButton;
@property (strong) IBOutlet NSImageView *qrCodeImageView;
@property (strong) IBOutlet NSGridView *gridView;
@property (strong) IBOutlet NSPopUpButton *typePopUpButton;

@property (nonatomic, readonly) KPKEntry *representedEntry;
@property (copy) KPKTimeOTPGenerator *generator;

@end

typedef NS_ENUM(NSUInteger, MPOTPUpdateSource) {
  MPOTPUpdateSourceQRImage,
  MPOTPUpdateSourceURL,
  MPOTPUpdateSourceSecret,
  MPOTPUpdateSourceAlgorithm,
  MPOTPUpdateSourceTimeSlice,
  MPOTPUpdateSourceType,
  MPOTPUpdateSourceDigits,
  MPOTPUpdateSourceEntry
};

typedef NS_ENUM(NSUInteger, MPOTPType) {
  MPOTPTypeRFC,
  MPOTPTypeSteam,
  MPOTPTypeCustom
};

@implementation MPTOTPSetupViewController

- (KPKEntry *)representedEntry {
  if([self.representedObject isKindOfClass:KPKEntry.class]) {
    return (KPKEntry *)self.representedObject;
  }
  return nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self _setupView];
  [self _updateView:MPOTPUpdateSourceEntry];
}

- (IBAction)changeType:(id)sender {
  if(sender != self.typePopUpButton) {
    return; // wrong sender
  }
  [self _updateView:MPOTPUpdateSourceType];
}

- (IBAction)changeHashAlgorithm:(id)sender {
  [self _updateView:MPOTPUpdateSourceAlgorithm];
}

- (IBAction)changeDigits:(id)sender {
  [self _updateView:MPOTPUpdateSourceDigits];
}

- (IBAction)changeTimeSlice:(id)sender {
  [self _updateView:MPOTPUpdateSourceTimeSlice];
}

- (IBAction)parseQRCode:(id)sender {
  if(sender != self.qrCodeImageView) {
    return; // wrong sender
  }
  [self _updateView:MPOTPUpdateSourceQRImage];
}

- (IBAction)cancel:(id)sender {
  [self.presentingViewController dismissViewController:self];
}

- (IBAction)save:(id)sender {
  // Update entry settings!
  // FIXME: add model observing to ensure correct history recording
  [self.view.window makeFirstResponder:nil];
  [self.generator saveToEntry:self.representedEntry];
  [self.presentingViewController dismissViewController:self];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
  NSControl *control = notification.object;
  if(control == self.secretTextField) {
    [self _updateView:MPOTPUpdateSourceSecret];
  }
  else if(control == self.urlTextField) {
    [self _updateView:MPOTPUpdateSourceURL];
  }
  else if(control == self.timeStepTextField) {
    [self _updateView:MPOTPUpdateSourceTimeSlice];
  }
}

- (void)_setupView {
  /* algorithm */
  NSMenuItem *sha1Item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HASH_SHA1", "SHA 1 hash algoritm menu item") action:NULL keyEquivalent:@""];
  sha1Item.tag = KPKOTPHashAlgorithmSha1;
  NSMenuItem *sha256Item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HASH_SHA256", "SHA 256 hash algoritm menu item") action:NULL keyEquivalent:@""];
  sha256Item.tag = KPKOTPHashAlgorithmSha256;
  NSMenuItem *sha512Item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HASH_SHA512", "SHA 512 hash algoritm menu item") action:NULL keyEquivalent:@""];
  sha512Item.tag = KPKOTPHashAlgorithmSha512;
  
  NSAssert(self.algorithmPopUpButton.menu.numberOfItems == 0, @"Hash algorithm menu needs to be empty");
  [self.algorithmPopUpButton.menu addItem:sha1Item];
  [self.algorithmPopUpButton.menu addItem:sha256Item];
  [self.algorithmPopUpButton.menu addItem:sha512Item];
  
  self.algorithmPopUpButton.action = @selector(changeHashAlgorithm:);
  self.algorithmPopUpButton.target = self;
  
  /* digits */
  NSAssert(self.digitCountPopUpButton.menu.numberOfItems == 0, @"Digit menu needs to be empty");
  for(NSUInteger digit = 6; digit <= 8; digit++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld", digit] action:NULL keyEquivalent:@""];
    item.tag = digit;
    [self.digitCountPopUpButton.menu addItem:item];
  }
  
  self.digitCountPopUpButton.action = @selector(changeDigits:);
  self.digitCountPopUpButton.target = self;
  
  
  NSAssert(self.typePopUpButton.menu.numberOfItems == 0, @"Type menu needs to be empty!");
  NSMenuItem *rfcItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OTP_RFC", @"OTP type RFC ") action:NULL keyEquivalent:@""];
  rfcItem.tag = MPOTPTypeRFC;
  NSMenuItem *steamItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OTP_STEAM", @"OTP type Steam ") action:NULL keyEquivalent:@""];
  steamItem.tag = MPOTPTypeSteam;
  NSMenuItem *customItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OTP_CUSTOM", @"OTP custom type ") action:NULL keyEquivalent:@""];
  customItem.tag = MPOTPTypeCustom;
  
  [self.typePopUpButton.menu addItem:rfcItem];
  [self.typePopUpButton.menu addItem:steamItem];
  [self.typePopUpButton.menu addItem:customItem];
  
  self.typePopUpButton.action = @selector(changeType:);
  self.typePopUpButton.target = self;
  
  self.timeStepTextField.stringValue = @"";
  self.timeStepStepper.integerValue = 0;
  
  self.timeStepStepper.action = @selector(changeTimeSlice:);
  /*[self.timeStepTextField bind:NSValueBinding
                      toObject:self
                   withKeyPath:NSStringFromSelector(@selector(timeSlice))
                       options:nil];
  [self.timeStepStepper bind:NSValueBinding
                    toObject:self
                 withKeyPath:NSStringFromSelector(@selector(timeSlice))
                     options:@{ NSConditionallySetsEnabledBindingOption:@(NO), NSConditionallySetsEditableBindingOption:@(NO)}];*/
  
  self.secretTextField.delegate = self;
  self.urlTextField.delegate = self;
  
}

- (void)_updateView:(MPOTPUpdateSource)source {
  /*
   MPOTPUpdateSourceQRImage,
   MPOTPUpdateSourceURL,
   MPOTPUpdateSourceSecret,
   MPOTPUpdateSourceAlgorithm,
   MPOTPUpdateSourceTimeSlice,
   MPOTPUpdateSourceType,
   MPOTPUpdateSourceEntry
   */
  if(source != MPOTPUpdateSourceEntry) {
    NSAssert(self.generator, @"OTP Generator needs to be set when change source is not entry");
  }
  
  BOOL enableCustomSettings = NO;
  switch(source) {
    case MPOTPUpdateSourceType: {
      MPOTPType otpType = self.typePopUpButton.selectedTag;
      NSData *oldKey = self.generator.key;
      switch(otpType) {
        case MPOTPTypeCustom:
          enableCustomSettings = YES;
        case MPOTPTypeRFC:
          self.generator = [[KPKTimeOTPGenerator alloc] init]; // initialize a RFC otp generator for custom and rfc types
          self.generator.key = oldKey;
          break;
        case MPOTPTypeSteam:
          self.generator = [[KPKSteamOTPGenerator alloc] init]; // initialize a default Steam OTP generator
          self.generator.key = oldKey;
      }
    }
      break;
    case MPOTPUpdateSourceQRImage: {
      NSString *qrCodeString = self.qrCodeImageView.image.QRCodeString;
      NSURL *otpURL = [NSURL URLWithString:qrCodeString];
      self.generator = otpURL.isSteamOTPURL ? [[KPKSteamOTPGenerator alloc] initWithURL:qrCodeString] : [[KPKTimeOTPGenerator alloc] initWithURL:qrCodeString];
      break;
    }
    case MPOTPUpdateSourceURL:{
      NSURL *otpURL = [NSURL URLWithString:self.urlTextField.stringValue];
      if(otpURL.isSteamOTPURL) {
        self.generator = [[KPKSteamOTPGenerator alloc] initWithURL:self.urlTextField.stringValue];
      }
      else if(otpURL.isTimeOTPURL) {
        self.generator = [[KPKTimeOTPGenerator alloc] initWithURL:self.urlTextField.stringValue];
      }
      else {
        // invalid URL
      }
      break;
    }
      
    case MPOTPUpdateSourceEntry:
      if(self.representedEntry.hasTimeOTP) {
        if(self.representedEntry.hasSteamOTP) {
          self.generator = [[KPKSteamOTPGenerator alloc] initWithAttributes:self.representedEntry.attributes];
        }
        else {
          self.generator = [[KPKTimeOTPGenerator alloc] initWithAttributes:self.representedEntry.attributes];
        }
      }
      else {
        self.generator = [[KPKTimeOTPGenerator alloc] init];
      }
      break;
    case MPOTPUpdateSourceSecret:
      self.generator.key = [NSData dataWithBase32EncodedString:self.secretTextField.stringValue];
      break;
    case MPOTPUpdateSourceAlgorithm:
      self.generator.hashAlgorithm = (KPKOTPHashAlgorithm)self.algorithmPopUpButton.selectedTag;
      break;
    case MPOTPUpdateSourceTimeSlice:
      self.generator.timeSlice = self.timeStepStepper.integerValue;
      break;
    case MPOTPUpdateSourceDigits:
      self.generator.numberOfDigits = self.digitCountPopUpButton.selectedTag;
      break;
    default:
      break;
  }
  
  /*
   The KPKOTPGenerator is the sole data source. We do not need to query anything else
   */
  
  if(!self.generator) {
    // display issues!
    return;
  }
  
  /* update display data with current generator */
  BOOL isSteam = [self.generator isKindOfClass:KPKSteamOTPGenerator.class];
  
  if((self.generator.isRFC6238 && !enableCustomSettings) || isSteam) {
    if(isSteam) {
      [self.typePopUpButton selectItemWithTag:MPOTPTypeSteam];
    }
    else {
      [self.typePopUpButton selectItemWithTag:MPOTPTypeRFC];
    }
    self.digitCountPopUpButton.enabled = NO;
    self.algorithmPopUpButton.enabled = NO;
    self.timeStepStepper.enabled = NO;
    self.timeStepTextField.enabled = NO;
  }
  else {
    [self.typePopUpButton selectItemWithTag:MPOTPTypeCustom];
    self.digitCountPopUpButton.enabled = YES;
    self.algorithmPopUpButton.enabled = YES;
    self.timeStepStepper.enabled = YES;
    self.timeStepTextField.enabled = YES;
  }
  
  NSURL *authURL;
  if(isSteam) {
    authURL = [NSURL URLWIthSteamOTPKey:self.generator.key issuer:self.representedEntry.title];
  }
  else {
    authURL = [NSURL URLWithTimeOTPKey:self.generator.key
                             algorithm:self.generator.hashAlgorithm
                                issuer:self.representedEntry.title
                                period:self.generator.timeSlice
                                digits:self.generator.numberOfDigits];
  }
   
  if(!(authURL && authURL.isTimeOTPURL)) {
    // display issue!
    return;
  }
  
  self.urlTextField.stringValue = authURL.absoluteString;
  self.qrCodeImageView.image = [NSImage QRCodeImageWithString:authURL.absoluteString];
  
  NSString *secret = [self.generator.key base32EncodedStringWithOptions:0];
  self.secretTextField.stringValue = secret ? secret : @"";
  [self.algorithmPopUpButton selectItemWithTag:self.generator.hashAlgorithm];
  [self.digitCountPopUpButton selectItemWithTag:self.generator.numberOfDigits];
  self.timeStepStepper.integerValue = self.generator.timeSlice;
  self.timeStepTextField.stringValue = self.timeStepStepper.stringValue;
}

@end
