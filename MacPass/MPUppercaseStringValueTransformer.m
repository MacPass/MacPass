//
//  MPUppercaseStringValueTransformer.m
//  MacPass
//
//  Created by Michael Starke on 03.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPUppercaseStringValueTransformer.h"

NSString *const MPUppsercaseStringValueTransformerName = @"com.hicknhack.macpass.StringToUppercaseStringTransformer";

@implementation MPUppercaseStringValueTransformer

+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (void)registerTransformer {
  MPUppercaseStringValueTransformer *transformer = [[MPUppercaseStringValueTransformer alloc] init];
  [NSValueTransformer setValueTransformer:transformer
                                  forName:MPUppsercaseStringValueTransformerName];
  [transformer release];
}

- (id)transformedValue:(id)value {
  if([value respondsToSelector:@selector(uppercaseString)]) {
    return [value uppercaseString];
  }
  return value;
}

@end
