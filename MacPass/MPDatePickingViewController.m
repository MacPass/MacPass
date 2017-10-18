//
//  MPDatePickingViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

@property (nullable, weak) IBOutlet NSDatePicker *datePicker;
@property (nullable, weak) IBOutlet NSPopUpButton *presetPopupButton;

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

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
  if(self.representedObject) {
    self.datePicker.dateValue = [self.representedObject timeInfo].expirationDate;
  }
}

- (IBAction)useDate:(id)sender {
  [self.observer willChangeModelProperty];
  [self.representedObject timeInfo].expirationDate = self.datePicker.dateValue;
  [self.observer didChangeModelProperty];
  [self.view.window performClose:sender];
}

- (IBAction)cancel:(id)sender {
  [self.view.window performClose:sender];
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
  self.datePicker.dateValue = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
}

@end
