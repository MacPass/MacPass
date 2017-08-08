//
//  MPValueTransformerHelper.m
//  MacPass
//
//  Created by Michael Starke on 17/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPValueTransformerHelper.h"
#import "NSValueTransformer+TransformerKit.h"

NSString *const MPStripLineBreaksTransformerName = @"com.hicknhack.macpass.MPStripLineBreaksTransformerName";
NSString *const MPExpiryDateValueTransformerName = @"com.hicknhack.macpass.MPExpiryDateValueTransformer";
NSString *const MPTokenValueTransformerName = @"com.hicknhack.macpass.MPTokenValueTransformer";
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
                      if(![value isKindOfClass:NSDate.class]) {
                        return NSLocalizedString(@"NO_EXPIRE_DATE_SET","");
                      }
                      static NSDateFormatter *formatter;
                      if(!formatter) {
                        formatter = [[NSDateFormatter alloc] init];
                        formatter.dateStyle = kCFDateFormatterLongStyle;
                        formatter.timeStyle = NSDateFormatterNoStyle;
                      }

                      if([value isEqualToDate:[NSDate distantFuture]]) {
                        return NSLocalizedString(@"NO_EXPIRE_DATE_SET", "");
                      }

                      NSString *template = NSLocalizedString(@"EXPIRES_AT_DATE_%@", "");
                      return [[NSString alloc] initWithFormat:template, [formatter stringFromDate:value]];
                    }];

  [NSValueTransformer registerValueTransformerWithName:MPTokenValueTransformerName
                                 transformedValueClass:NSArray.class
                    returningTransformedValueWithBlock:^id(NSArray *value) {
                      return [value filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                        return [evaluatedObject length];
                      }]];
                    }];
}

@end
