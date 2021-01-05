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
@property (strong) IBOutlet NSPopUpButton *digitCountPopUpButton;
@property (strong) IBOutlet NSImageView *qrCodeImageView;
@property (strong) IBOutlet NSGridView *gridView;

@property (strong) KPKTimeOTPGenerator *generator;

@end

@implementation MPTOTPSetupViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSAssert([self.representedObject isKindOfClass:KPKEntry.class], @"represented object needs to be a KPKEntry");
  self.generator = [[KPKTimeOTPGenerator alloc] initWithEntry:((KPKEntry *)self.representedObject)];
  
  /**/
  KPKEntry *entry = self.representedObject;
  NSString *url = [entry attributeWithKey:kKPKAttributeKeyOTPOAuthURL].value;
  self.urlTextField.stringValue = url ? url : @"";
  
  /* secret */
  NSString *secret = [self.generator.key base32EncodedString];
  self.secretTextField.stringValue = secret ? secret : @"";
  
  /* algorithm */
  NSMenuItem *sha1Item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HASH_SHA1", "SHA 1 hash algoritm menu item") action:NULL keyEquivalent:@""];
  sha1Item.tag = KPKOTPHashAlgorithmSha1;
  NSMenuItem *sha256Item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HASH_SHA256", "SHA 256 hash algoritm menu item") action:NULL keyEquivalent:@""];
  sha256Item.tag = KPKOTPHashAlgorithmSha256;
  NSMenuItem *sha512Item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HASH_SHA512", "SHA 512 hash algoritm menu item") action:NULL keyEquivalent:@""];
  sha512Item.tag = KPKOTPHashAlgorithmSha512;
  
  [self.algorithmPopUpButton.menu removeAllItems];
  [self.algorithmPopUpButton.menu addItem:sha1Item];
  [self.algorithmPopUpButton.menu addItem:sha256Item];
  [self.algorithmPopUpButton.menu addItem:sha512Item];
  
  [self.algorithmPopUpButton selectItemWithTag:self.generator.hashAlgorithm];
  
  /* digits */
  [self.digitCountPopUpButton.menu removeAllItems];
  for(NSUInteger digit = 6; digit <= 8; digit++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld", digit] action:NULL keyEquivalent:@""];
    item.tag = digit;
    [self.digitCountPopUpButton.menu addItem:item];
  }
  [self.digitCountPopUpButton selectItemWithTag:self.generator.numberOfDigits];
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
  NSString *qrCodeString = self.qrCodeImageView.image.QRCodeString;
  NSURL *otpURL = [NSURL URLWithString:qrCodeString];
  if(!otpURL.isTimeOTPURL) {
    return; // no valid URL
  }
  self.urlTextField.stringValue = otpURL.absoluteString;
}

@end
