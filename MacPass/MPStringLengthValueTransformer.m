//
//  MPStringLengthValueTransformer.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPStringLengthValueTransformer.h"
#define CROP_LENGHT 10;

NSString *const MPStringLengthValueTransformerName = @"com.hicknhack.macpass.MPMPStringLengthValueTransformer";

@implementation MPStringLengthValueTransformer

+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (void)registerTransformer {
  MPStringLengthValueTransformer *transformer = [[MPStringLengthValueTransformer alloc] init];
  [NSValueTransformer setValueTransformer:transformer
                                  forName:MPStringLengthValueTransformerName];
}

- (id)transformedValue:(id)value {
  NSUInteger length = 0;
  if([value isKindOfClass:[NSString class]]) {
    length = [value length];
  }
  return (length > 0) ? @"12345678" : @"";
}

@end
