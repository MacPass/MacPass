//
//  MPActionHelper.m
//  MacPass
//
//  Created by Michael Starke on 09.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPActionHelper.h"

@implementation MPActionHelper

+ (NSDictionary *)_actionDictionary {
  static NSDictionary *actionDict;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    actionDict = @{
                   @(MPActionAddEntry) : @"createEntry:",
                   @(MPActionAddGroup) : @"createGroup:",
                   @(MPActionCopyPassword) : @"copyPassword:",
                   @(MPActionCopyURL) : @"copyURL:",
                   @(MPActionCopyUsername) : @"copyUsername:",
                   @(MPActionDelete) : @"deleteNode:",
                   @(MPActionOpenURL) : @"openURL:",
                   @(MPActionToggleInspector) : @"toggleInspector:",
                   @(MPActionLock) : @"lock:",
                   @(MPActionEmptyTrash) : @"emptyTrash:",
                   @(MPActionDatabaseSettings) : @"showDatabaseSettings:"
                   };
  });
  return actionDict;
}

+ (SEL)actionOfType:(MPActionType)type {
  NSDictionary *actionDict = [self _actionDictionary];
  return NSSelectorFromString(actionDict[@(type)]);
}

+ (MPActionType)typeForAction:(SEL)action {
  NSString *selectorString = NSStringFromSelector(action);
  NSArray *selectors = [[self _actionDictionary] allValues];
  NSUInteger index = [selectors indexOfObject:selectorString];
  if(index == NSNotFound) {
    return MPUnkownAction;
  }
  NSArray *keys = [[self _actionDictionary] allKeysForObject:selectorString];
  NSAssert([keys count] == 1, @"There should only be one object for the specified key");
  return [[keys lastObject] integerValue];
}


@end
