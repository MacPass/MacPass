//
//  MPOTPViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPTOTPViewController.h"

#import <KeePassKit/KeePassKit.h>
#import "MPEntryInspectorViewController.h"
#import "MPPasteBoardController.h"

@interface MPTOTPViewController ()

@property (strong) KPKTimeOTPGenerator *generator;

@end

@implementation MPTOTPViewController

- (void)viewDidLoad {
  self.remainingTimeButton.title = @"";
  self.toptValueTextField.buttonTitle = NSLocalizedString(@"COPY", @"Copy the TOTP value to the clipboard");
  __weak MPTOTPViewController *welf = self;
  self.toptValueTextField.buttonActionBlock = (^void(NSTextField *tf) {
    NSText *text = [welf.view.window fieldEditor:NO forObject:welf.toptValueTextField];
    if([text isKindOfClass:NSTextView.class]) {
      [welf textField:welf.toptValueTextField textView:(NSTextView *)text performAction:@selector(copy:)];
    }
  });
}

- (IBAction)showOTPSetup:(id)sender {
  MPEntryInspectorViewController *vs = (MPEntryInspectorViewController*)self.parentViewController;
  [vs showOTPSetup:sender];
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

- (BOOL)textField:(NSTextField *)textField textView:(NSTextView *)textView performAction:(SEL)action {
  if(action == @selector(copy:)) {
    MPPasteboardOverlayInfoType info = MPPasteboardOverlayInfoCustom;
    NSMutableString *selectedValue = [[NSMutableString alloc] init];
    for(NSValue *rangeValue in textView.selectedRanges) {
      [selectedValue appendString:[textView.string substringWithRange:rangeValue.rangeValue]];
    }
    if(selectedValue.length == 0) {
      [selectedValue setString:textField.stringValue];
    }
    NSString *name = NSLocalizedString(@"TOTP", "Field TOTP was copied to the pasteboard");
    [MPPasteBoardController.defaultController copyObject:selectedValue overlayInfo:info name:name atView:self.view];
    return NO;
  }
  return YES;
}


- (void)_didChangeAttribute:(NSNotification *)notification {
  [self _updateDisplay];
}

- (void)_updateDisplay {
  KPKEntry *entry = (KPKEntry *)self.representedObject;
  BOOL showTOTP = entry.hasTimeOTP;
  self.view.hidden = !showTOTP;
  if(showTOTP) {
    
    self.generator = entry.hasSteamOTP ? [[KPKSteamOTPGenerator alloc] initWithAttributes:entry.attributes] : [[KPKTimeOTPGenerator alloc] initWithAttributes:entry.attributes];
    self.generator.time = NSDate.date.timeIntervalSince1970;
    NSString *stringValue = self.generator.string;
    self.toptValueTextField.stringValue = stringValue ? stringValue : @"";
    
    NSString *template = NSLocalizedString(@"TOTP_REMAINING_TIME_%ld_SECONDS", @"Time in seconds remaining for a valid TOTP string, format should be %ld");
    
    self.remainingTimeButton.title = [NSString stringWithFormat:template, (NSUInteger)self.generator.remainingTime];
    [self performSelector:@selector(_updateDisplay) withObject:nil afterDelay:0.5];
  }
  else {
    self.remainingTimeButton.title = @"";
    self.toptValueTextField.stringValue = @"";
  }
}
@end
