//
//  MPEntryProxy.m
//  MacPass
//
//  Created by Michael Starke on 07/03/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryProxy.h"
#import <KeePassKit/KeePassKit.h>

@interface MPEntryProxy ()

@property (strong) KPKEntry *entry;

@end

@implementation MPEntryProxy

- (instancetype)initWithEntry:(KPKEntry *)entry {
  if(!entry) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
  }
  _entry = entry;
  return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  NSLog(@"forwardInvocation: %@", NSStringFromSelector(invocation.selector));
  [invocation invokeWithTarget:self.entry];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  NSLog(@"methodSignatureForSelector %@", NSStringFromSelector(sel));
  return [self.entry methodSignatureForSelector:sel];
}

@end
