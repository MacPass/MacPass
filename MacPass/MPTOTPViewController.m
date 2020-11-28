//
//  MPOTPViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPTOTPViewController.h"

#import "KPKEntry+OTP.h"

#import <KeePassKit/KeePassKit.h>

@interface MPTOTPViewController ()

@property (strong) KPKOTPGenerator *otpGenerator;

@end

@implementation MPTOTPViewController

- (void)viewDidLoad {
  self.otpGenerator = [[KPKOTPGenerator alloc] init];
  [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
  NSArray *notificationNames = @[KPKWillAddAttributeNotification, KPKDidAddAttributeNotification, KPKWillChangeAttributeNotification, KPKDidChangeAttributeNotification, KPKWillRemoveAttributeNotification, KPKDidRemoveAttributeNotification];
  if(self.representedObject) {
    for(NSString *notificationName in notificationNames) {
      [NSNotificationCenter.defaultCenter removeObserver:self name:notificationName object:self.representedObject];
    }
  }
  super.representedObject = representedObject;
  if(representedObject) {
    for(NSString *notificationName in notificationNames) {
      [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didChangeAttribute:) name:notificationName object:representedObject];
    }
  }
  [self _didChangeAttribute:nil];
}

- (void)_didChangeAttribute:(NSNotification *)notification {
  KPKEntry *entry = (KPKEntry *)self.representedObject;
  BOOL showTOTP = entry.hasTOTP;
  self.view.hidden = !showTOTP;
  if(showTOTP) {
    self.remainingTimeProgressIndicator.indeterminate = YES;
  }
  else {
    self.remainingTimeProgressIndicator.indeterminate = NO;
  }
}

@end
