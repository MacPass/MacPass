//
//  MPAutotypeBuilderViewController.m
//  MacPass
//
//  Created by Michael Starke on 01/09/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeBuilderViewController.h"
#import <KeePassKit/KeePassKit.h>

@interface MPAutotypeBuilderViewController () <NSTokenFieldDelegate>

@property (weak) IBOutlet NSTokenField *availableCommandsTokenField;
@property (weak) IBOutlet NSTokenField *commandBuilderTokenField;

@property (nonatomic, readonly, strong) NSArray<NSString *> *tokens;

@end

@implementation MPAutotypeBuilderViewController

#define _MPToken(short,long) [NSString stringWithFormat:@"%@ %@", short, long]

- (NSArray<NSString *> *)tokens {
  static NSArray *_tokens;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    for(NSString *attribute in [KPKFormat sharedFormat].entryDefaultKeys) {
      [fields addObject:[NSString stringWithFormat:@"{%@}", attribute]];
    }
    [fields addObject:@"{S:Custom}"];
    _tokens = [fields arrayByAddingObjectsFromArray:@[ _MPToken(kKPKAutotypeShortEnter, kKPKAutotypeEnter),
                                                       _MPToken(kKPKAutotypeShortAlt, kKPKAutotypeAlt),
                                                       _MPToken(kKPKAutotypeShortControl, kKPKAutotypeControl),
                                                       ]];
  });
  return _tokens;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)nibName {
  return @"AutotypeBuilderView";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.availableCommandsTokenField.editable = NO;
  self.availableCommandsTokenField.objectValue = self.tokens;
  self.availableCommandsTokenField.delegate = self;
  self.commandBuilderTokenField.delegate = self;
}

- (IBAction)addCustomKeyPlaceholder:(id)sender {
  if(![sender isKindOfClass:NSMenuItem.class]) {
    return;
  }
  NSMenuItem *item = sender;
  NSArray *tokens = [self.commandBuilderTokenField.objectValue arrayByAddingObject:[NSString stringWithFormat:@"{S:%@}", item.title]];
  self.commandBuilderTokenField.objectValue = tokens;
}

- (NSMenu *)tokenField:(NSTokenField *)tokenField menuForRepresentedObject:(id)representedObject {
  if(tokenField == self.commandBuilderTokenField) {
    return nil;
  }
  if([[representedObject uppercaseString] hasPrefix:@"{S:"]) {
    KPKEntry *entry = self.representedObject;
    NSArray <KPKAttribute *> *customAttributes = entry.customAttributes;
    if(customAttributes.count > 0 ) {
      NSMenu *menu = [[NSMenu alloc] init];
      for(KPKAttribute *attribute in customAttributes) {
        [menu addItemWithTitle:attribute.key action:@selector(addCustomKeyPlaceholder:) keyEquivalent:@""];
      }
      return menu;
    }
  }
  return nil;
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject {
  if(tokenField != self.availableCommandsTokenField) {
    return NO;
  }
  BOOL showMenu = ([[representedObject uppercaseString] hasPrefix:@"{S:"] && [self.representedObject customAttributes].count > 0);
  return showMenu;
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject {
  if(tokenField == self.availableCommandsTokenField) {
    return NSTokenStyleDefault;
  }
  if([representedObject hasPrefix:@"{"] || [representedObject hasSuffix:@"}"]) {
    return NSTokenStyleDefault;
  }
  return NSTokenStyleNone;
}

@end
