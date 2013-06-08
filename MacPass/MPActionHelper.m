//
//  MPActionHelper.m
//  MacPass
//
//  Created by Michael Starke on 09.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPActionHelper.h"

@implementation MPActionHelper

+ (SEL)actionOfType:(MPActionType)type {
  static NSDictionary *actionDict;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    actionDict = [@{
                  @(MPActionAddEntry) : @"createEntry:",
                  @(MPActionAddGroup) : @"createGroup:",
                  @(MPActionCopyPassword) : @"copyPassword:",
                  @(MPActionCopyURL) : @"copyURL:",
                  @(MPActionCopyUsername) : @"copyUsername:",
                  @(MPActionDelete) : @"deleteEntry:",
                  @(MPActionEdit) : @"editEntry:",
                  @(MPActionOpenURL) : @"openURL:",
                  @(MPActionToggleInspector) : @"toggleInspector:",
                  @(MPActionLock) : @"lock:"
                  } retain];
  });
  return NSSelectorFromString(actionDict[@(type)]);
}

@end
