//
//  MPLoggerProxy.m
//  MacPass
//
//  Created by michael starke on 26.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPLoggerProxy.h"

@implementation MPLoggerProxy

- (id) initWithOriginal:(id)value {
  if (self = [super init]) {
    self.original = value;
  }
  return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  NSMethodSignature *sig = [super methodSignatureForSelector:sel];
  if(!sig)
  {
    sig = [self.original methodSignatureForSelector:sel];
  }
  return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv {
  NSLog(@"[%@ %@] %@ %@", self.original, inv,[inv methodSignature],
        NSStringFromSelector([inv selector]));
  [inv invokeWithTarget:self.original];
}

@end
