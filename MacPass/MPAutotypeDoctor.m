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
#import "MPAutotypeDoctorReportViewController.h"
#import "NSError+Messages.h"


@interface MPReportItem : NSObject

@property (copy) NSString *statusDescription;
@property (copy) NSString *label;
@property (copy) NSString *actionLabel;
@property BOOL isOK;
@property (weak) id target;

@end

@implementation MPReportItem

- (instancetype)init {
  self = [super init];
  if(self) {
    _isOK = NO;
  }
  return self;
}

@end


@interface MPAutotypeDoctor () <NSWindowDelegate>
@property (strong) NSWindow *reportWindow;
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

- (BOOL)hasNecessaryAutotypePermissions {
  if(![self hasAccessibiltyPermissions:NULL]) {
    return NO;
  }
  if(![self hasScreenRecordingPermissions:NULL]) {
    return NO;
  }
  return YES;
}

- (BOOL)hasScreenRecordingPermissions:(NSError *__autoreleasing*)error {
  /* macos 10.14 and lower do not require screen recording permission to get window titles */
  
  /*
   Solution is heavily inspired by Craig Hockenberry's
   https://stackoverflow.com/questions/56597221/detecting-screen-recording-settings-on-macos-catalina/58985069#58985069
   */
  if(@available(macOS 10.15, *)) {
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSUInteger numberOfWindows = CFArrayGetCount(windowList);
    BOOL canRecordScreen = NO;
    for(int idx = 0; idx < numberOfWindows; idx++) {
      NSDictionary *windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, idx);
      NSNumber *ownerPid = windowInfo[(id)kCGWindowOwnerPID];
      /*
       Skip over our own windows
       */
      if(ownerPid.intValue == NSProcessInfo.processInfo.processIdentifier) {
        continue;
      }
      /*
       Skip applications we aren't allowed to access anyway
       */
      NSRunningApplication *ownerApp = [NSRunningApplication runningApplicationWithProcessIdentifier:ownerPid.intValue];
      if(!ownerApp) {
        continue;
      }
      NSString *windowName = windowInfo[(id)kCGWindowName];
      if(windowName) {
        if([ownerApp.executableURL.lastPathComponent isEqualToString:@"Dock"]) {
          continue;
        }
        canRecordScreen = YES;
        break;
      }
    }
    CFRelease(windowList);
    if(!canRecordScreen && error) {
      *error = [NSError errorInDomain:MPAutotypeErrorDomain withCode:MPErrorAutotypeIsMissingScreenRecordingPermissions description:NSLocalizedString(@"ERROR_NO_PERMISSION_TO_RECORD_SCREEN", "Error description for missing screen recording permissions")];
    }
    return canRecordScreen;
  }
  return YES;
}

- (BOOL)hasAccessibiltyPermissions:(NSError *__autoreleasing*)error {
  BOOL isTrusted = YES;
  /* macOS 10.13 and lower allows us to send key events regardless of accessibilty trust */
  if(@available(macOS 10.14, *)) {
    isTrusted = AXIsProcessTrusted();
    if(!isTrusted && error) {
      *error = [NSError errorInDomain:MPAutotypeErrorDomain withCode:MPErrorAutotypeIsMissingAccessibiltyPermissions description:NSLocalizedString(@"ERROR_NO_ACCESSIBILITY_PERMISSIONS", "Error description for missing accessibility permissions")];
    }
  }
  return isTrusted;
}

- (void)openAccessibiltyPreferences {
  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]];
}

- (void)openScreenRecordingPreferences {
  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"]];
}

- (void)requestScreenRecordingPermission {
  /* macos 10.14 and lower do not require screen recording permission to get window titles */
  if(@available(macos 10.15, *)) {
    /*
     To minimize the intrusion just make a 1px image of the upper left corner
     This way there is no real possibilty to access any private data
     */
    CGImageRef screenshot = CGWindowListCreateImage(
                                                    CGRectMake(0, 0, 1, 1),
                                                    kCGWindowListOptionOnScreenOnly,
                                                    kCGNullWindowID,
                                                    kCGWindowImageDefault);
    CFRelease(screenshot);
  }
}

- (void)openAutomationPreferences {
  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"]];
}

- (void)runChecksAndPresentResults {
  if(!self.reportWindow) {
    self.reportWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                                    styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
    self.reportWindow.releasedWhenClosed = NO;
    self.reportWindow.title = NSLocalizedString(@"AUTOTYPE_DOCTOR_RESULTS_WINDOW_TITLE", @"Window title for the stand-alone password creator window");
    self.reportWindow.delegate = self;
  }
  MPAutotypeDoctorReportViewController *vc = [[MPAutotypeDoctorReportViewController alloc] init];
  self.reportWindow.contentViewController = vc;
  
  [self.reportWindow center];
  [self.reportWindow makeKeyAndOrderFront:vc];
}

- (void)windowWillClose:(NSNotification *)notification {
  if(notification.object == self.reportWindow) {
    self.reportWindow = nil;
  }
}

@end
