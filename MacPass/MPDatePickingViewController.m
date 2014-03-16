//
//  MPDatePickingViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatePickingViewController.h"

typedef NS_ENUM(NSUInteger, MPDatePresets) {
  MPDatePresetTomorrow,
  MPDatePresetOneWeek,
  MPDatePresetOneMonth,
  MPDatePresetOneYear,
};

@interface MPDatePickingViewController ()

@property (strong) NSDate *date;

@end

@implementation MPDatePickingViewController

- (id)init {
  self = [self initWithNibName:@"DatePickingView" bundle:nil];
  return self;
}

- (void)awakeFromNib {
  NSMenu *presetMenu = [[NSMenu alloc] init];
  NSDictionary *dateItems = @{ @(MPDatePresetTomorrow): NSLocalizedString(@"TOMORROW", ""),
                               @(MPDatePresetOneWeek): NSLocalizedString(@"ONE_WEEK", ""),
                               @(MPDatePresetOneMonth): NSLocalizedString(@"ONE_MONTH", ""),
                               @(MPDatePresetOneYear): NSLocalizedString(@"ONE_YEAR", "") };
  for(NSNumber *tagNumber in dateItems) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:dateItems[tagNumber] action:NULL keyEquivalent:@""];
    [item setTag:[tagNumber integerValue]];
    [presetMenu addItem:item];
  }
  
  [self.presetPopupButton setMenu:presetMenu];
}

- (IBAction)useDate:(id)sender {
  self.date = [self.datePicker dateValue];
  id target = [NSApp targetForAction:@selector(performClose:)];
  [target performClose:sender];
}

- (IBAction)cancel:(id)sender {
  self.date = [NSDate distantFuture];
  id target = [NSApp targetForAction:@selector(performClose:)];
  [target performClose:sender];
}
@end
