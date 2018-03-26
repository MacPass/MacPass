//
//  MPPrettyPasswordTransformer.m
//  MacPass
//
//  Created by Michael Starke on 01.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPPrettyPasswordTransformer.h"
#import "NSString+MPPrettyPasswordDisplay.h"

NSString *const MPPrettyPasswordTransformerName = @"com.hicknhack.macpass.MPPrettyPasswordTransformerName";

@implementation MPPrettyPasswordTransformer

+ (Class)transformedValueClass {
  return NSAttributedString.class;
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

+ (void)registerTransformer {
 MPPrettyPasswordTransformer *transformer = [[MPPrettyPasswordTransformer alloc] init];
  [NSValueTransformer setValueTransformer:transformer
                                  forName:MPPrettyPasswordTransformerName];
}

- (id)transformedValue:(id)value {
  if([value isKindOfClass:NSString.class]) {
    return ((NSString *)value).passwordPrettified;
  }
  if([value isKindOfClass:NSAttributedString.class]) {
    return ((NSAttributedString *)value).string;
  }
  return nil;
}


@end
