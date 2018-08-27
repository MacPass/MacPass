//
//  MPPickfieldTableModel.m
//  MacPass
//
//  Created by Michael Starke on 28.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPPickfieldTableModel.h"
#import <KeePassKit/KeePassKit.h>

@implementation MPPickfieldTableModelRowItem

- (instancetype)init {
  self = [super init];
  if(self) {
    _isGroup = NO;
  }
  return self;
}

+ (instancetype)groupItemWithName:(NSString *)name {
  MPPickfieldTableModelRowItem *item =  [self itemWithName:name value:nil];
  item.isGroup = YES;
  return item;
}

+ (instancetype)itemWithName:(NSString *)name value:(NSString *)value {
  MPPickfieldTableModelRowItem *item = [[MPPickfieldTableModelRowItem alloc] init];
  item.name = name;
  item.value = value;
  return item;
}

@end

@implementation MPPickfieldTableModel

- (instancetype)initWithEntry:(KPKEntry *)entry inDocument:(MPDocument *)document {
  self = [super init];
  if(self) {
    [self _setupItemsForEntry:entry document:document];
  }
  return self;
}

- (void)_setupItemsForEntry:(KPKEntry *)entry document:(MPDocument *)document {
  /* Default attributes */
  NSMutableArray *items = [[NSMutableArray alloc] init];
  [items addObject:[MPPickfieldTableModelRowItem groupItemWithName:NSLocalizedString(@"ENTRY_DEFAULT_ATTRIBUTES", @"Group row for entry attributes")]];
  
  for(KPKAttribute *attribute in entry.defaultAttributes) {
    /* TODO exclude protected values */
    [items addObject:[MPPickfieldTableModelRowItem itemWithName:attribute.key value:(attribute.protect ? @"•••" : attribute.value)]];
  }

  [items addObject:[MPPickfieldTableModelRowItem groupItemWithName:NSLocalizedString(@"ENTRY_CUSTOM_ATTRIBUTES", @"Group row for entry attributes")]];
  for(KPKAttribute *attribute in entry.customAttributes) {
    [items addObject:[MPPickfieldTableModelRowItem itemWithName:attribute.key value:(attribute.protect ? @"•••" : attribute.value)]];
  }
  self.items = items; // copy creates an immutable copy
}

- (MPPickfieldTableModelRowItem *)itemAtIndex:(NSUInteger)index {
  if(index < _items.count) {
    return _items[index];
  }
  return nil;
}

@end
