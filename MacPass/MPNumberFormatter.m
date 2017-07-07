//
//  MPNumberFormatter.m
//  MacPass
//
//  Created by Michael Starke on 24/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPNumberFormatter.h"

@implementation MPNumberFormatter

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  self.minimum = [NSDecimalNumber one];
  self.formatterBehavior = NSNumberFormatterBehavior10_4;
  self.allowsFloats = NO;
  self.alwaysShowsDecimalSeparator = NO;
  return self;
}

- (BOOL)getObjectValue:(out id __nullable * __nullable)obj forString:(NSString *)string errorDescription:(out NSString * __nullable * __nullable)error {
  /* If super can pase without an error, all is fine */
  if([super getObjectValue:obj forString:string errorDescription:error]) {
    return YES;
  }
  /* TODO adhere to minimum/maxiumum? */
  *obj = [self.minimum copy];
  return YES;
}


@end
