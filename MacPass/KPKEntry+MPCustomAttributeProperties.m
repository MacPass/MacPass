//
//  KPKEntry+MPCustomAttributeProperties.m
//  MacPass
//
//  Created by Michael Starke on 03.09.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "KPKEntry+MPCustomAttributeProperties.h"

NSString *const MPCustomAttributePropertyPrefix = @"valueForCustomAttribute";

@implementation KPKEntry (MPCustomAttributeProperties)

/*- (void)forwardInvocation:(NSInvocation *)anInvocation {
  NSString *selector = NSStringFromSelector(anInvocation.selector);
  if([selector hasPrefix:MPCustomAttributePropertyPrefix]) {
    NSString *key = [selector substringFromIndex:MPCustomAttributePropertyPrefix.length];
    KPKAttribute *attribute = [self attributeWithKey:key];
    if(attribute) {
      anInvocation.selector = @selector(value);
      [anInvocation invokeWithTarget:attribute];
    }
    else {
      anInvocation.selector = @selector(_unkownCustomAttributeValue);
      [anInvocation invokeWithTarget:self];
    }
  }
  else [super forwardInvocation:anInvocation];
}*/

- (NSString *)_unkownCustomAttributeValue {
  return @"";
}

@end
