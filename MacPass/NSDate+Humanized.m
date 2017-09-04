//
//  NSDate+Humanized.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
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

#import "NSDate+Humanized.h"

@implementation NSDate (Humanized)

+ (NSString *)humanizedDate:(NSDate *)date {
  return [date humanized];
}

- (NSString *)humanized {
  NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay|NSCalendarUnitWeekOfMonth|NSCalendarUnitMonth fromDate:self toDate:[NSDate date] options:0];
  /* More than one month in the past, give full date */
  if(components.month > 1) {
    return [NSDateFormatter localizedStringFromDate:self
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
  }
  NSUInteger weeks = components.weekOfMonth;
  /* More than one week, less than a month */
  if(weeks > 1) {
    NSString *weekTemplate = NSLocalizedString(@"%ld_WEEKS_AGO", "% Weeks ago");
    return [NSString stringWithFormat:weekTemplate, weeks];
  }
  /* One week or more */
  if( weeks == 1) {
    return NSLocalizedString(@"ONE_WEEK_AGO", "one week ago");
  }
  /* Last week */
  NSUInteger days = components.day;
  if(days > 3) {
    return NSLocalizedString(@"LAST_WEEK", "last week");
  }
  /* 1-3 days */
  if(days > 1 ) {
    NSString *daysTemplate = NSLocalizedString(@"%ld_DAYS_AGO", "% days ago");
    return [NSString stringWithFormat:daysTemplate, days];
  }
  /* Yesterday */
  if(days == 1) {
    return NSLocalizedString(@"YESTERDAY", "Yesterday");
  }
  /* Hours ago */
  if(components.hour > 1) {
    NSString *hourTemplate = NSLocalizedString(@"%ld_HOURS_AGO", "% Hours ago");
    return [NSString stringWithFormat:hourTemplate, components.hour];
  }
  if(components.minute > 1) {
    NSString *minuteTemplate = NSLocalizedString(@"%ld_MINUTES_AGO", "% Minutes ago");
    return [NSString stringWithFormat:minuteTemplate, components.minute];
  }
  return NSLocalizedString(@"JUST_NOW", "Just now");
}
@end
