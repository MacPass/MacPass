//
//  NSDate+Humanized.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSDate+Humanized.h"

@implementation NSDate (Humanized)

+ (NSString *)humanizedDate:(NSDate *)date {
  return [date humanized];
}

- (NSString *)humanized {
  NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *components = [calendar components:NSMinuteCalendarUnit|NSHourCalendarUnit|NSDayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit fromDate:self toDate:[NSDate date] options:0];
  /* More than one month in the past, give full date */
  if([components month] > 1) {
    return [NSDateFormatter localizedStringFromDate:self
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
  }
  NSUInteger weeks = [components week];
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
  NSUInteger days = [components day];
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
  if([components hour] > 1) {
    NSString *hourTemplate = NSLocalizedString(@"%ld_HOURS_AGO", "% Hours ago");
    return [NSString stringWithFormat:hourTemplate, [components hour]];
  }
  NSInteger minutes = [components minute];
  if(minutes > 1) {
    NSString *minuteTemplate = NSLocalizedString(@"%ld_MINUTES_AGO", "% Minutes ago");
    return [NSString stringWithFormat:minuteTemplate, minutes];
  }
  return NSLocalizedString(@"JUST_NOW", "Just now");
}
@end
