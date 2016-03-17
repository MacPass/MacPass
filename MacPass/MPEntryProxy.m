//
//  MPEntryProxy.m
//  MacPass
//
//  Created by Michael Starke on 07/03/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryProxy.h"
#import <KeePassKit/KeePassKit.h>

@interface MPSubEntryProxy : NSProxy

@property (weak) MPEntryProxy *entryProxy;
@property (nonatomic, readonly) id target;

- (instancetype)initWithEntryProxy:(MPEntryProxy *)entryProxy;

@end

@implementation MPSubEntryProxy

- (instancetype)initWithEntryProxy:(MPEntryProxy *)entryProxy {
  _entryProxy = entryProxy;
  return self;
}

- (id)target {
  return nil;
}

@end


@interface MPAutotypeProxy : MPSubEntryProxy
@end

@implementation MPAutotypeProxy

- (id)target {
  return self.entryProxy.entry.autotype;
}

@end

@interface MPTimeInfoProxy : MPSubEntryProxy
@end

@implementation MPTimeInfoProxy

- (id)target {
  return self.entryProxy.entry.timeInfo;
}

@end

#pragma mark -

@interface MPEntryProxy ()

@property (strong) KPKEntry *entry;
@property (strong) KPKEntry *changedEntry;

@end

@implementation MPEntryProxy

- (NSSet *)mutatingSelectors {
  static NSSet *set;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    set = [NSSet setWithArray:@[ [NSValue valueWithPointer:@selector(addCustomAttribute:)],
                                 [NSValue valueWithPointer:@selector(removeCustomAttribute:)],
                                 [NSValue valueWithPointer:@selector(addBinary:)],
                                 [NSValue valueWithPointer:@selector(removeBinary:)],
                                 [NSValue valueWithPointer:@selector(addAssociation:)],
                                 [NSValue valueWithPointer:@selector(removeAssociation:)] ]];
  });
  return set;
}

- (instancetype)initWithEntry:(KPKEntry *)entry {
  if(!entry) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
  }
  _entry = entry;
  return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  NSString *seletor = NSStringFromSelector(invocation.selector);
  if([[self mutatingSelectors] containsObject:[NSValue valueWithPointer:invocation.selector]]) {
    NSLog(@"Mutation detected.");
  }
  
  if([seletor hasPrefix:@"set"]) {
    NSLog(@"forwardInvocation: setter detected");
  }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  NSLog(@"methodSignatureForSelector %@", NSStringFromSelector(sel));
  return [self.entry methodSignatureForSelector:sel];
}

@end
