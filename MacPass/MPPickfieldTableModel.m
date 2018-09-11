//
//  MPPickfieldTableModel.m
//  MacPass
//
//  Created by Michael Starke on 28.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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
