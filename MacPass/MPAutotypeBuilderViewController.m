//
//  MPAutotypeBuilderViewController.m
//  MacPass
//
//  Created by Michael Starke on 01/09/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    for(NSString *attribute in KPKFormat.sharedFormat.entryDefaultKeys) {
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
  [NSNotificationCenter.defaultCenter removeObserver:self];
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

- (void)setSequence:(NSString *)sequence {
  self.commandBuilderTokenField.stringValue = sequence;
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
    if(entry.hasCustomAttributes ) {
      NSMenu *menu = [[NSMenu alloc] init];
      for(KPKAttribute *attribute in entry.customAttributes) {
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
  BOOL showMenu = ([[representedObject uppercaseString] hasPrefix:@"{S:"] && [self.representedObject hasCustomAttributes]);
  return showMenu;
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject {
  if(tokenField == self.availableCommandsTokenField) {
    return NSTokenStyleSquared;
  }
  if([representedObject hasPrefix:@"{"] || [representedObject hasSuffix:@"}"]) {
    return NSTokenStyleSquared;
  }
  return NSTokenStyleNone;
}

@end
