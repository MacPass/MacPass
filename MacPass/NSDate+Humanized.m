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
  NSDateComponents *components = [calendar components:NSMinuteCalendarUnit|NSHourCalendarUnit|NSDayCalendarUnit fromDate:self toDate:[NSDate date] options:0];
  if([components day] > 1) {
    return [NSDateFormatter localizedStringFromDate:self
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
  }
  if([components day] == 1) {
    return NSLocalizedString(@"YESTERDAY", "Yesterday");
  }
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
