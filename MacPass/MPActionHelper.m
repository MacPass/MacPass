//
//  MPActionHelper.m
//  MacPass
//
//  Created by Michael Starke on 09.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPActionHelper.h"
#import "MPDocument+HistoryBrowsing.h"
#import "MPEntryInspectorViewController.h"

@implementation MPActionHelper

+ (NSDictionary *)_actionDictionary {
  static NSDictionary *actionDict;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    actionDict = @{
                   @(MPActionAddEntry):               @"createEntry:",
                   @(MPActionAddGroup):               @"createGroup:",
                   @(MPActionCloneEntry):             @"cloneEntry:",
                   @(MPActionCloneEntryWithOptions):  @"cloneEntryWithOptions:",
                   @(MPActionCopyPassword):           @"copyPassword:",
                   @(MPActionCopyURL):                @"copyURL:",
                   @(MPActionCopyUsername):           @"copyUsername:",
                   @(MPActionDelete):                 @"delete:",
                   @(MPActionEditPassword):           @"editPassword:",
                   @(MPActionOpenURL):                @"openURL:",
                   @(MPActionToggleInspector):        @"toggleInspector:",
                   @(MPActionLock):                   @"lock:",
                   @(MPActionEmptyTrash):             @"emptyTrash:",
                   @(MPActionDatabaseSettings):       @"showDatabaseSettings:",
                   @(MPActionEditTemplateGroup):      @"editTemplateGroup:",
                   @(MPActionExportXML):              @"exportAsXML:",
                   @(MPActionImportXML):              @"importFromXMl:",
                   @(MPActionToggleQuicklook):        NSStringFromSelector(@selector(toggleQuicklookPreview:)),
                   @(MPActionShowHistory):            NSStringFromSelector(@selector(showHistory:)),
                   @(MPActionExitHistory):            NSStringFromSelector(@selector(exitHistory:))
                   };
  });
  return actionDict;
}

+ (SEL)actionOfType:(MPActionType)type {
  NSDictionary *actionDict = [self _actionDictionary];
  return NSSelectorFromString(actionDict[@(type)]);
}

+ (NSString *)keyEquivalentForAction:(MPActionType)type {
  static NSDictionary *keyEquivalentDictionary;
  static unichar backspaceCharacter = NSBackspaceCharacter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    keyEquivalentDictionary = @{ @(MPActionDelete): [[NSString alloc] initWithCharacters:&backspaceCharacter length:1] };
  });
  NSString *keyEquivalent = keyEquivalentDictionary[@(type)];
  return keyEquivalent ? keyEquivalent : @"";
}

+ (MPActionType)typeForAction:(SEL)action {
  NSString *selectorString = NSStringFromSelector(action);
  NSArray *selectors = [[self _actionDictionary] allValues];
  NSUInteger index = [selectors indexOfObject:selectorString];
  if(index == NSNotFound) {
    // Test for default Actions?
    return MPUnkownAction;
  }
  NSArray *keys = [[self _actionDictionary] allKeysForObject:selectorString];
  NSAssert([keys count] == 1, @"There should only be one object for the specified key");
  return [[keys lastObject] integerValue];
}


@end
