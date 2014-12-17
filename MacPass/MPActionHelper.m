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
#import "MPEntryViewController.h"
#import "MPDocumentWindowController.h"

@implementation MPActionHelper

+ (NSDictionary *)_actionDictionary {
  static NSDictionary *actionDict;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    actionDict = @{
                   @(MPActionAddEntry):                         NSStringFromSelector(@selector(createEntry:)),
                   @(MPActionAddGroup):                         NSStringFromSelector(@selector(createGroup:)),
                   @(MPActionDuplicateEntry):                   NSStringFromSelector(@selector(duplicateEntry:)),
                   @(MPActionDuplicateEntryWithOptions):        NSStringFromSelector(@selector(duplicateEntryWithOptions:)),
                   @(MPActionCopyPassword):                     NSStringFromSelector(@selector(copyPassword:)),
                   @(MPActionCopyURL):                          NSStringFromSelector(@selector(copyURL:)),
                   @(MPActionCopyUsername):                     NSStringFromSelector(@selector(copyUsername:)),
                   @(MPActionDelete):                           NSStringFromSelector(@selector(delete:)),
                   @(MPActionEditPassword):                     NSStringFromSelector(@selector(editPassword:)),
                   @(MPActionOpenURL):                          NSStringFromSelector(@selector(openURL:)),
                   @(MPActionToggleInspector):                  NSStringFromSelector(@selector(toggleInspector:)),
                   @(MPActionLock):                             NSStringFromSelector(@selector(lock:)),
                   @(MPActionEmptyTrash):                       NSStringFromSelector(@selector(emptyTrash:)),
                   @(MPActionDatabaseSettings):                 NSStringFromSelector(@selector(showDatabaseSettings:)),
                   @(MPActionEditTemplateGroup):                NSStringFromSelector(@selector(editTemplateGroup:)),
                   @(MPActionExportXML):                        NSStringFromSelector(@selector(exportAsXML:)),
                   @(MPActionImportXML):                        NSStringFromSelector(@selector(importFromXML:)),
                   @(MPActionToggleQuicklook):                  NSStringFromSelector(@selector(toggleQuicklookPreview:)),
                   @(MPActionShowHistory):                      NSStringFromSelector(@selector(showHistory:)),
                   @(MPActionExitHistory):                      NSStringFromSelector(@selector(exitHistory:)),
                   @(MPActionPerformAutotypeForSelectedEntry):  NSStringFromSelector(@selector(performAutotypeForEntry:))
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
