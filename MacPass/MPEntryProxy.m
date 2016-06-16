//
//  MPEntryProxy.m
//  MacPass
//
//  Created by Michael Starke on 07/03/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryProxy.h"
#import <KeePassKit/KeePassKit.h>

#pragma mark -

@interface MPEntryProxy ()

@property (strong) KPKEntry *entry;
@property BOOL firstModification;

@end

@implementation MPEntryProxy
- (instancetype)initWithEntry:(KPKEntry *)entry {
  if(!entry) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
  }
  _entry = entry;
  _firstModification = NO;
  
  return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  if(invocation.selector == @selector(touchModified)) {
    if(self.firstModification) {
      [self.entry pushHistory];
      self.firstModification = YES;
    }
    NSLog(@"Possible mutation detected. Creating backup!");
  }
  invocation.target = self.entry;
  [invocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  NSLog(@"methodSignatureForSelector %@", NSStringFromSelector(sel));
  return [self.entry methodSignatureForSelector:sel];
}

@end
