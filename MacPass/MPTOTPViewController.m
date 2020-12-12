//
//  MPOTPViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPTOTPViewController.h"

#import <KeePassKit/KeePassKit.h>

@interface MPTOTPViewController ()

@end

@implementation MPTOTPViewController

- (void)viewDidLoad {
  self.remainingTimeProgressIndicator.minValue = 0;
  self.remainingTimeProgressIndicator.maxValue = 30;
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
  [self _updateDisplay];
}

- (void)_updateDisplay {
  KPKEntry *entry = (KPKEntry *)self.representedObject;
  BOOL showTOTP = entry.hasTimeOTP;
  self.view.hidden = !showTOTP;
  if(showTOTP) {
    self.remainingTimeProgressIndicator.indeterminate = YES;
    self.toptValueTextField.stringValue = entry.timeOTP;
    self.remainingTimeProgressIndicator.doubleValue = 0;
    [self performSelector:@selector(_updateDisplay) withObject:nil afterDelay:0.5];
  }
  else {
    self.remainingTimeProgressIndicator.indeterminate = NO;
    self.toptValueTextField.stringValue = @"";
  }
}
@end
