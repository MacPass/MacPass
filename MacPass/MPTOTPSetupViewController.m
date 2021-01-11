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

@property (strong) KPKTimeOTPGenerator *generator;
@property NSInteger timeSlice;

@end

typedef NS_ENUM(NSUInteger, MPOTPUpdateSource) {
  MPOTPUpdateSourceQRImage,
  MPOTPUpdateSourceURL,
  MPOTPUpdateSourceSecret,
  MPOTPUpdateSourceAlgorithm,
  MPOTPUpdateSourceTimeSlice,
  MPOTPUpdateSourceEntry
};

typedef NS_ENUM(NSUInteger, MPOTPType) {
  MPOTPTypeRFC,
  MPOTPTypeSteam,
  MPOTPTypeCustom
};

@implementation MPTOTPSetupViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSAssert([self.representedObject isKindOfClass:KPKEntry.class], @"represented object needs to be a KPKEntry");

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
  
  [self _updateView:MPOTPUpdateSourceEntry];
}

- (IBAction)toggleDisclosure:(id)sender {
  for(NSInteger row = 1; row < self.gridView.numberOfRows; row++) {
    NSGridRow *gridRow = [self.gridView rowAtIndex:row];
    gridRow.hidden = !gridRow.hidden;
  }
}

- (IBAction)parseQRCode:(id)sender {
  if(sender != self.qrCodeImageView) {
    return; // wrong sender
  }
  [self _updateView:MPOTPUpdateSourceQRImage];
}

- (void)_updateView:(MPOTPUpdateSource)source {
  self.generator = [[KPKTimeOTPGenerator alloc] initWithEntry:((KPKEntry *)self.representedObject)];
  
  if(source == MPOTPUpdateSourceQRImage) {
    NSString *qrCodeString = self.qrCodeImageView.image.QRCodeString;
    NSURL *otpURL = [NSURL URLWithString:qrCodeString];
    if(!otpURL.isTimeOTPURL) {
      return; // no valid URL
    }
    self.urlTextField.stringValue = otpURL.absoluteString;
  }

  
  /* FIXME: update correct values based on changes */

  /* URL and QR code */
  KPKEntry *entry = self.representedObject;
  NSString *url = [entry attributeWithKey:kKPKAttributeKeyOTPOAuthURL].value;
  
  self.urlTextField.stringValue = @"";
  
  if(url) {
    NSURL *authURL = [NSURL URLWithString:url];
    if(authURL.isTimeOTPURL) {
      self.urlTextField.stringValue = authURL.absoluteString;
      self.qrCodeImageView.image = [NSImage QRCodeImageWithString:authURL.absoluteString];
    }
  }
  
  /* secret */
  NSString *secret = [self.generator.key base32EncodedString];
  self.secretTextField.stringValue = secret ? secret : @"";

  [self.algorithmPopUpButton selectItemWithTag:self.generator.hashAlgorithm];
  
  [self.digitCountPopUpButton selectItemWithTag:self.generator.numberOfDigits];
    
  self.timeSlice = self.generator.timeSlice;
 
}

@end
