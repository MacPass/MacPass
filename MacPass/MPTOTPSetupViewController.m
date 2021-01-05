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

@end

@implementation MPTOTPSetupViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do view setup here.
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
