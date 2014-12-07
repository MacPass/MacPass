//
//  MPDatePickingViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatePickingViewController.h"

#import "MPDocument.h"
#import "KPKNode.h"
#import "KPKTimeInfo.h"

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
  [item setTag:MPDatePresetNone];
  [presetMenu addItem:item];
  [presetMenu addItem:[NSMenuItem separatorItem]];
  
  for(NSInteger iIndex = 0; iIndex < sizeof(tags)/sizeof(NSUInteger); iIndex++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:dateItems[iIndex] action:NULL keyEquivalent:@""];
    [item setTag:tags[iIndex]];
    [presetMenu addItem:item];
  }
  
  [self.datePicker setDateValue:[NSDate date]];
  [self.presetPopupButton setAction:@selector(setDatePreset:)];
  [self.presetPopupButton setMenu:presetMenu];
}

- (IBAction)useDate:(id)sender {
  self.didCancel = NO;
  self.date = [self.datePicker dateValue];
  [self.popover performClose:self];
}

- (IBAction)cancel:(id)sender {
  self.didCancel = YES;
  [self.popover performClose:self];
}

- (IBAction)setDatePreset:(id)sender {
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
  
  MPDatePreset preset = [[sender selectedItem] tag];
  switch(preset) {
    case MPDatePresetTomorrow:
      [offsetComponents setDay:1];
      break;
    case MPDatePresetOneWeek:
      [offsetComponents setWeek:1];
      break;
    case MPDatePresetOneMonth:
      [offsetComponents setMonth:1];
      break;
    case MPDatePreset90Days:
      [offsetComponents setDay:90];
      break;
    case MPDatePresetOneYear:
      [offsetComponents setYear:1];
      break;
    case MPDatePresetNone:
    default:
      return; // Nothing to do;
  }
  NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
  [self.datePicker setDateValue:newDate];
}

@end
