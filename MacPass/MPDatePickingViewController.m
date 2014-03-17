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
  NSUInteger tags[] = { MPDatePresetTomorrow, MPDatePresetOneWeek, MPDatePresetOneMonth, MPDatePresetOneYear };
  NSArray *dateItems = @[ NSLocalizedString(@"TOMORROW", ""), NSLocalizedString(@"ONE_WEEK", ""), NSLocalizedString(@"ONE_MONTH", ""), NSLocalizedString(@"ONE_YEAR", "") ];
  for(NSInteger iIndex = 0; iIndex < sizeof(tags)/sizeof(NSUInteger); iIndex++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:dateItems[iIndex] action:NULL keyEquivalent:@""];
    [item setTag:tags[iIndex]];
    [presetMenu addItem:item];
  }
  
  MPDocument *document = [[self windowController] document];
  
  [self.datePicker setDateValue:document.selectedItem.timeInfo.expiryTime];
  [self.presetPopupButton setAction:@selector(setDatePreset:)];
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
    case MPDatePresetOneYear:
      [offsetComponents setYear:1];
      break;
    default:
      break;
  }
  NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
  [self.datePicker setDateValue:newDate];
}

@end
