//
//  MPDatePickingViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatePickingViewController.h"

#import "MPDocument.h"

#import "KeePassKit/KeePassKit.h"

typedef NS_ENUM(NSUInteger, MPDatePreset) {
  MPDatePresetNone,
  MPDatePresetTomorrow,
  MPDatePresetOneWeek,
  MPDatePresetOneMonth,
  MPDatePreset90Days,
  MPDatePresetOneYear,
};

@interface MPDatePickingViewController ()

@property (assign) BOOL didCancel;

@end

@implementation MPDatePickingViewController

- (NSString *)nibName {
  return @"DatePickingView";
}

- (void)awakeFromNib {
  NSMenu *presetMenu = [[NSMenu alloc] init];
  NSUInteger tags[] = { MPDatePresetTomorrow, MPDatePresetOneWeek, MPDatePresetOneMonth, MPDatePreset90Days, MPDatePresetOneYear };
  NSArray *dateItems = @[ NSLocalizedString(@"TOMORROW", ""), NSLocalizedString(@"ONE_WEEK", ""), NSLocalizedString(@"ONE_MONTH", ""), NSLocalizedString(@"90_DAYS", ""), NSLocalizedString(@"ONE_YEAR", "") ];
  
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SELECT_DATE_PRESET", "") action:NULL keyEquivalent:@""];
  item.tag = MPDatePresetNone;
  [presetMenu addItem:item];
  [presetMenu addItem:[NSMenuItem separatorItem]];
  
  for(NSInteger iIndex = 0; iIndex < sizeof(tags)/sizeof(NSUInteger); iIndex++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:dateItems[iIndex] action:NULL keyEquivalent:@""];
    item.tag = tags[iIndex];
    [presetMenu addItem:item];
  }
  
  self.datePicker.dateValue = [NSDate date];
  self.presetPopupButton.menu = presetMenu;
}

- (IBAction)useDate:(id)sender {
  self.didCancel = NO;
  self.date = self.datePicker.dateValue;
  [self.popover performClose:self];
}

- (IBAction)cancel:(id)sender {
  self.didCancel = YES;
  [self.popover performClose:self];
}

- (IBAction)setDatePreset:(id)sender {
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];

  MPDatePreset preset = ((NSPopUpButton *)sender).selectedTag;
  switch(preset) {
    case MPDatePresetTomorrow:
      offsetComponents.day = 1;
      break;
    case MPDatePresetOneWeek:
      offsetComponents.weekOfMonth = 1;
      break;
    case MPDatePresetOneMonth:
      offsetComponents.month = 1;
      break;
    case MPDatePreset90Days:
      offsetComponents.day = 90;
      break;
    case MPDatePresetOneYear:
      offsetComponents.year = 1;
      break;
    case MPDatePresetNone:
    default:
      return; // Nothing to do;
  }
  NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
  self.datePicker.dateValue = newDate;
}

@end
