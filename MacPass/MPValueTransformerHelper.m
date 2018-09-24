//
//  MPValueTransformerHelper.m
//  MacPass
//
//  Created by Michael Starke on 17/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
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

#import "MPValueTransformerHelper.h"
#import "NSValueTransformer+TransformerKit.h"

NSString *const MPStripLineBreaksTransformerName = @"com.hicknhack.macpass.MPStripLineBreaksTransformerName";
NSString *const MPExpiryDateValueTransformerName = @"com.hicknhack.macpass.MPExpiryDateValueTransformer";
@implementation MPValueTransformerHelper

+ (void)registerValueTransformer {
  [NSValueTransformer registerValueTransformerWithName:MPStripLineBreaksTransformerName
                                 transformedValueClass:NSString.class
                    returningTransformedValueWithBlock:^id(id value) {
                      if(![value isKindOfClass:NSString.class]) {
                        return @"";
                      }
                      NSArray *elements = [value componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
                      return [elements componentsJoinedByString:@" "];
                    }];
  
  
  [NSValueTransformer registerValueTransformerWithName:MPExpiryDateValueTransformerName
                                 transformedValueClass:NSString.class
                    returningTransformedValueWithBlock:^id(id value) {
                      NSString * _Nonnull noExpirationDateString = NSLocalizedString(@"NO_EXPIRE_DATE_SET", "Expiration date format, when item does not expire");
                      if(![value isKindOfClass:NSDate.class]) {
                        return noExpirationDateString;
                      }
                      static NSDateFormatter *formatter;
                      if(!formatter) {
                        formatter = [[NSDateFormatter alloc] init];
                        formatter.dateStyle = kCFDateFormatterLongStyle;
                        formatter.timeStyle = NSDateFormatterNoStyle;
                      }

                      if([value isEqualToDate:NSDate.distantFuture]) {
                        return noExpirationDateString;
                      }

                      NSString *template = NSLocalizedString(@"EXPIRES_AT_DATE_%@", "Format to returen the date an item expires. Includes %@ placehoder for date");
                      return [[NSString alloc] initWithFormat:template, [formatter stringFromDate:value]];
                    }];
}

@end
