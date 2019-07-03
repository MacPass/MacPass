//
//  MPAutotypeDoctor.m
//  MacPass
//
//  Created by Michael Starke on 03.07.19.
//  Copyright © 2019 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDoctor.h"
#import "MPSettingsHelper.h"
#import "NSApplication+MPAdditions.h"

@interface MPAutotypeDoctor ()

@end

@implementation MPAutotypeDoctor

+ (MPAutotypeDoctor *)defaultDoctor {
  static MPAutotypeDoctor *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPAutotypeDoctor alloc] init];
  });
  return instance;
}

- (BOOL)hasScreenRecordingPermissions {
  /* macos 10.14 and lower do not require screen recording permission to get window titles */
  if(@available(macos 10.15, *)) {
    /*
     To minimize the intrusion just make a 1px image of the upper left corner
     This way there is no possibilty to access any private data
     */
    CGImageRef screenshot = CGWindowListCreateImage(
                                                    CGRectMake(0, 0, 1, 1),
                                                    kCGWindowListOptionOnScreenOnly,
                                                    kCGNullWindowID,
                                                    kCGWindowImageDefault);
    if(!screenshot) {
      return NO;
    }
  }
  return YES;
}

- (BOOL)hasAccessibiltyPermissions {
  if(@available(macOS 10.14, *)) {
    return AXIsProcessTrusted();
  }
  /* macOS 10.13 and lower allows us to send key events regardless of accessibilty trust */
  return YES;
}

- (NSString *)localizedErrorDescription {
  return @"TODO";
}

- (void)showPermissionCheckReport {
  // TODO
}

- (BOOL)checkPermissionsWithoutUserFeedback {
  // TODO
  return YES;
}

- (void)checkForAccessibiltyPermissions {
  if(NSApplication.sharedApplication.isRunningTests) {
    return; // Do not display pop-up when running tests
  }
  
  BOOL hideAlert = NO;
  if(nil != [NSUserDefaults.standardUserDefaults objectForKey:kMPSettingsKeyAutotypeHideAccessibiltyWarning]) {
    hideAlert = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyAutotypeHideAccessibiltyWarning];
  }
  if(hideAlert || self.hasAccessibiltyPermissions) {
    return;
  }
  else {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSWarningAlertStyle;
    alert.messageText = NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_MESSAGE_TEXT", @"Alert message displayed when Autotype performs self check and lacks accessibilty permissions");
    alert.informativeText = NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_INFORMATIVE_TEXT", @"Alert informative text displayed when Autotype performs self check and lacks accessibilty permissions");
    alert.showsSuppressionButton = YES;
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_BUTTON_OK", @"Button in dialog to leave autotype disabled and continiue!")];
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_AUTOTYPE_MISSING_ACCESSIBILTY_PERMISSIONS_BUTTON_OPEN_PREFERENCES", @"Button in dialog to open accessibilty preferences pane!")];
    NSModalResponse returnCode = [alert runModal];
    BOOL suppressWarning = (alert.suppressionButton.state == NSOnState);
    [NSUserDefaults.standardUserDefaults setBool:suppressWarning forKey:kMPSettingsKeyAutotypeHideAccessibiltyWarning];
    switch(returnCode) {
      case NSAlertFirstButtonReturn: {
        /* ok, ignore */
        break;
      }
      case NSAlertSecondButtonReturn:
        /* open prefs */
        [self openAccessibiltyPreferences];
        break;
      default:
        break;
    }
  }
}

- (void)openAccessibiltyPreferences {
  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]];
}

- (void)checkForWindowTitlePermissions {
}


@end
