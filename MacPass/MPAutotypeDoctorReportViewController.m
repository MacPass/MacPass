//
//  MPAutotypeDoctorReportViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.07.19.
//  Copyright © 2019 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDoctorReportViewController.h"
#import "MPAutotypeDoctor.h"

@implementation MPAutotypeDoctorReportViewController

- (NSNibName)nibName {
  return @"AutotypeDoctorReportViewController";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self _updateView];

}

- (void)openAccessibiltyPreferences:(id)sender {
  [MPAutotypeDoctor.defaultDoctor openAccessibiltyPreferences];
}

- (void)openScreenRecordingPreferences:(id)sender {
  [MPAutotypeDoctor.defaultDoctor openScreenRecordingPreferences];
}

- (IBAction)requestScreenRecordingPermissions:(id)sender {
  [MPAutotypeDoctor.defaultDoctor requestScreenRecordingPermission];
}

- (void)openAutomationPreferences:(id)sender {
  [MPAutotypeDoctor.defaultDoctor openAutomationPreferences];
}


- (void)_updateView {
  NSError *error;
  if([MPAutotypeDoctor.defaultDoctor hasAccessibiltyPermissions:&error]) {
    self.accessibiltyStatusImageView.image = [NSImage imageNamed:NSImageNameStatusAvailable];
    self.accessibiltyStatusTextField.stringValue = NSLocalizedString(@"AUTOTYPE_STATUS_ACCESSIBILTY_PERMISSIONS_OK", "Status label when no issue were found in accessibilty");
  }
  else {
    self.accessibiltyStatusImageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
    if(error && error.localizedDescription) {
      self.accessibiltyStatusTextField.stringValue = error.localizedDescription;
    }
    else {
      self.accessibiltyStatusTextField.stringValue = NSLocalizedString(@"AUTOTYPE_STATUS_NO_ACCESSIBILTY_PERMISSIONS", "Status MacPass has no accessibilty permissions");
    }
  }
  if([MPAutotypeDoctor.defaultDoctor hasScreenRecordingPermissions:&error]) {
    self.requestScreenRecordingButton.enabled = NO;
    self.screenRecordingStatusImageView.image = [NSImage imageNamed:NSImageNameStatusAvailable];
    self.screenRecordingStatusTextField.stringValue = NSLocalizedString(@"AUTOTYPE_STATUS_SCREEN_RECORDING_PERMISSIONS_OK", "Status label when no issue were found in screen recording permissions");
  }
  else {
    self.requestScreenRecordingButton.enabled = YES;
    self.screenRecordingStatusImageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
    if(error && error.localizedDescription) {
      self.screenRecordingStatusTextField.stringValue = error.localizedDescription;
    }
    else {
      self.screenRecordingStatusTextField.stringValue = NSLocalizedString(@"AUTOTYPE_STATUS_NO_SCREEN_RECORDING_PERMISSIONS", "Status MacPass has no screen recording permissions");
    }
  } 
}

@end
