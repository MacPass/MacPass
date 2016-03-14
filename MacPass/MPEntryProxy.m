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
@property (strong) NSMutableDictionary *valueStore;

@end

@implementation MPEntryProxy

- (instancetype)initWithEntry:(KPKEntry *)entry {
  if(!entry) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
  }
  _entry = entry;
  _valueStore = [[NSMutableDictionary alloc] init];
  return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  NSLog(@"forwardInvocation: %@", NSStringFromSelector(invocation.selector));
  NSString *seletor = NSStringFromSelector(invocation.selector);
  if([seletor hasPrefix:@"set"]) {
    NSLog(@"forwardInvocation: setter detected");
    NSString *property = [seletor substringFromIndex:3].lowercaseString; // lowercase fist letter!!!
    if(invocation.methodSignature.numberOfArguments == 3) {
      id value;
      [invocation getArgument:&value atIndex:2];
      NSLog(@"forwardInvocation: captured value %@", value);
      if(value) {
        self.valueStore[property] = value;
      }
      return; // captures getter, just return
    }
  }
  id change = self.valueStore[seletor.lowercaseString];
  if(change) {
    NSLog(@"forwardInvocation: hit cached value. Returning cache!");
    [invocation setReturnValue:&change];
  }
  else {
    [invocation invokeWithTarget:self.entry];
  }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  NSLog(@"methodSignatureForSelector %@", NSStringFromSelector(sel));
  return [self.entry methodSignatureForSelector:sel];
}

@end
