//
//  MPStripLineBreaksTransformer.m
//  MacPass
//
//  Created by Michael Starke on 31.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPStripLineBreaksTransformer.h"

NSString *const MPStripLineBreaksTransformerName = @"com.hicknhack.macpass.MPStripLineBreaksTransformerName";

@implementation MPStripLineBreaksTransformer

+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (void)registerTransformer {
  MPStripLineBreaksTransformer *transformer = [[MPStripLineBreaksTransformer alloc] init];
  [NSValueTransformer setValueTransformer:transformer
                                  forName:MPStripLineBreaksTransformerName];
}

- (id)transformedValue:(id)value {
  if(![value isKindOfClass:[NSString class]]) {
    return nil;
  }
  NSArray *elements = [value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  return [elements componentsJoinedByString:@" "];
}

@end
