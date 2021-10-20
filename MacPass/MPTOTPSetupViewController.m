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

@property NSInteger timeSlice;

@end

typedef NS_ENUM(NSUInteger, MPOTPUpdateSource) {
  MPOTPUpdateSourceQRImage,
  MPOTPUpdateSourceURL,
  MPOTPUpdateSourceSecret,
  MPOTPUpdateSourceAlgorithm,
  MPOTPUpdateSourceTimeSlice,
  MPOTPUpdateSourceType,
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
  MPOTPType type = self.typePopUpButton.selectedItem.tag;
  switch(type) {
    case MPOTPTypeRFC:
    case MPOTPTypeSteam:
      self.algorithmPopUpButton.enabled = NO;
      self.digitCountPopUpButton.enabled = NO;
      self.timeStepStepper.enabled = NO;
      break;
    case MPOTPTypeCustom:
      self.algorithmPopUpButton.enabled = YES;
      self.digitCountPopUpButton.enabled = YES;
      self.timeStepStepper.enabled = YES;
  }
  [self _updateView:MPOTPUpdateSourceType];
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
  // adhere to change observation for history?
  [self.presentingViewController dismissViewController:self];
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
  
  /* digits */
  NSAssert(self.digitCountPopUpButton.menu.numberOfItems == 0, @"Digit menu needs to be empty");
  for(NSUInteger digit = 6; digit <= 8; digit++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld", digit] action:NULL keyEquivalent:@""];
    item.tag = digit;
    [self.digitCountPopUpButton.menu addItem:item];
  }
  
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
  
  [self.timeStepTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(timeSlice)) options:nil];
  [self.timeStepStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(timeSlice)) options:nil];
  
  KPKEntry *entry = self.representedEntry;
  if(entry.hasTimeOTP) {
    self.generator = [[KPKTimeOTPGenerator alloc] initWithAttributes:self.representedEntry.attributes];
    if(self.generator.isRFC6238) {
      [self.typePopUpButton selectItemWithTag:MPOTPTypeRFC];
    }
  }
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
  switch(source) {
    case MPOTPUpdateSourceQRImage: {
      NSString *qrCodeString = self.qrCodeImageView.image.QRCodeString;
      NSURL *otpURL = [NSURL URLWithString:qrCodeString];
      self.urlTextField.stringValue = otpURL.absoluteString;
      self.generator = [[KPKTimeOTPGenerator alloc] initWithURL:self.urlTextField.stringValue];
      break;
    }
    case MPOTPUpdateSourceURL:
      self.generator = [[KPKTimeOTPGenerator alloc] initWithURL:self.urlTextField.stringValue];
      break;
    
    case MPOTPUpdateSourceEntry:
      if(self.representedEntry.hasTimeOTP) {
        self.generator = [[KPKTimeOTPGenerator alloc] initWithAttributes:self.representedEntry.attributes];
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
      self.generator.timeSlice = self.timeStepTextField.integerValue;
      break;
    default:
      return;
  }
  
  /*
   The KPKTimeOTPGenerator is the sole data source. We do not need to query anything else
   */

  if(!self.generator) {
    // display issues!
    return;
  }

  NSURL *authURL = [NSURL URLWithTimeOTPKey:self.generator.data algorithm:self.generator.hashAlgorithm issuer:self.representedEntry.title period:self.generator.timeSlice digits:self.generator.numberOfDigits];
  if(!authURL || !authURL.isTimeOTPURL) {
    // display issues
    return;
  }
  
  self.urlTextField.stringValue = authURL.absoluteString;
  self.qrCodeImageView.image = [NSImage QRCodeImageWithString:authURL.absoluteString];

  /* secret */
  NSString *secret = [self.generator.key base32EncodedStringWithOptions:0];
  self.secretTextField.stringValue = secret ? secret : @"";
  [self.algorithmPopUpButton selectItemWithTag:self.generator.hashAlgorithm];
  [self.digitCountPopUpButton selectItemWithTag:self.generator.numberOfDigits];
  self.timeSlice = self.generator.timeSlice;
}

@end
