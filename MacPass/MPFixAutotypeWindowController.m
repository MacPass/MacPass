//
//  MPFixAutotypeWindowController.m
//  MacPass
//
//  Created by Michael Starke on 26/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
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

#import "MPFixAutotypeWindowController.h"

#import "MPDocument.h"
#import "MPIconHelper.h"

#import "KeePassKit/KeePassKit.h"


NSString *const kMPAutotypeCell = @"AutotypeCell";
NSString *const kMPTitleCell = @"TitleCell";
NSString *const kMPIsDefaultCell = @"IsDefaultCell";
NSString *const kMPIconCell = @"IconCell";


@interface KPKWindowAssociation (MPFixAutotypeWindowControllerQualifedName)

@property (nonatomic, readonly) NSString *qualifedName;

@end


@implementation KPKWindowAssociation (MPFixAutotypeWindowControllerQualifedName)

- (NSString *)qualifedName {
  return [[NSString alloc] initWithFormat:@"%@ (%@)", self.windowTitle, self.autotype.entry.title ];
}

@end

@interface MPFixAutotypeWindowController () {
  NSArray *_itemsCache;
  BOOL _didRegisterForUndoRedo;
}
@end


@implementation MPFixAutotypeWindowController

- (NSString *)windowNibName {
  return @"FixAutotypeWindow";
}

- (void)windowDidLoad {
  [super windowDidLoad];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.window performClose:self];
}


#pragma mark -
#pragma mark Properties
- (void)setDocument:(id)document {
  [super setDocument:document];
  if(!_didRegisterForUndoRedo) {
    NSUndoManager *manager = [document undoManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeDocument:) name:NSUndoManagerDidRedoChangeNotification object:manager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeDocument:) name:NSUndoManagerDidUndoChangeNotification object:manager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeDocument:) name:NSUndoManagerDidCloseUndoGroupNotification object:manager];
  }
  _itemsCache = nil;
  [self.tableView reloadData];
}

#pragma mark -
#pragma mark Actions

- (void)clearAutotype:(id)sender {
  [[self.document undoManager] beginUndoGrouping];
  NSIndexSet *indexes = [self.tableView selectedRowIndexes];
  MPFixAutotypeWindowController __weak *weakSelf = self;
  [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    id item = [weakSelf entriesAndGroups][idx];
    if([item isKindOfClass:[KPKEntry class]]){
      [item autotype].defaultKeystrokeSequence = nil;
    }
    else if([item isKindOfClass:[KPKGroup class]]) {
      [item setDefaultAutoTypeSequence:nil];
    }
    else {
      [item setKeystrokeSequence:nil];
    }
  }];
  [[self.document undoManager] endUndoGrouping];
  [[self.document undoManager] setActionName:NSLocalizedString(@"CLEAR_AUTOTYPE", @"Clear Autotype Button")];
  [self.tableView reloadDataForRowIndexes:indexes columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)]];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [[self entriesAndGroups] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  id item = [self entriesAndGroups][row];
  KPKGroup *group;
  KPKEntry *entry;
  KPKWindowAssociation *association;
  if([item isKindOfClass:[KPKEntry class]]) {
    entry = item;
  }
  else if([item isKindOfClass:[KPKGroup class]]) {
    group = item;
  }
  else if([item isKindOfClass:[KPKWindowAssociation class]]) {
    association = item;
  }
  
  if(nil == entry && nil == group && nil == association) {
    return nil;
  }
  
  if([[tableColumn identifier] isEqualToString:kMPTitleCell]) {
    if(entry) {
      return entry.title;
    }
    if(group) {
      return [group breadcrumbWithSeparator:@" > "];
    }
    return [association qualifedName];
  }
  else if ([[tableColumn identifier] isEqualToString:kMPAutotypeCell]) {
    if(entry) {
      return entry.autotype.defaultKeystrokeSequence;
    }
    if(group) {
      return group.defaultAutoTypeSequence;
    }
    return association.keystrokeSequence;
  }
  else {
    BOOL isMalformed = [MPDocument isCandidateForMalformedAutotype:item];
    BOOL isDefault = entry.autotype.hasDefaultKeystrokeSequence || group.hasDefaultAutotypeSequence || association.hasDefaultKeystrokeSequence;
    if([[tableColumn identifier] isEqualToString:kMPIsDefaultCell]) {
      return isDefault ? @"Yes" : @"No";
    }
    else if( [[tableColumn identifier] isEqualToString:kMPIconCell]) {
      return isMalformed ? [MPIconHelper icon:MPIconWarning] : nil;
    }
  }
  return nil;
}


- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  id item = [self entriesAndGroups][row];
  
  if([item isKindOfClass:[KPKEntry class]]) {
    ((KPKEntry *)item).autotype.defaultKeystrokeSequence = object;
  }
  else if([item isKindOfClass:[KPKGroup class]]) {
    ((KPKGroup *)item).defaultAutoTypeSequence = object;
  }
  else if([item isKindOfClass:[KPKWindowAssociation class]]) {
    ((KPKWindowAssociation *)item).keystrokeSequence = object;
  }
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  return [tableColumn.identifier isEqualToString:kMPAutotypeCell];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
  id item = [self entriesAndGroups][row];
  return [item isKindOfClass:[KPKGroup class]];
}

#pragma mark -
#pragma mark MenuItem Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if(!(menuItem.action == @selector(clearAutotype:))) {
    return NO;
  }
  return (self.tableView.selectedRowIndexes.count > 0);
}

#pragma mark -
#pragma mark Data accessors

- (NSArray *)entriesAndGroups {
  if(nil == _itemsCache) {
    _itemsCache = [self.document malformedAutotypeItems];
  }
  return _itemsCache;
}


- (void)flattenGroup:(KPKGroup *)group toArray:(NSMutableArray *)array {
  [array addObject:group];
  for(KPKEntry *entry in group.entries) {
    [array addObject:entry];
    [array addObjectsFromArray:entry.autotype.associations];
  }
  for(KPKGroup *childGroup in group.groups) {
    [self flattenGroup:childGroup toArray:array];
  }
}

#pragma mark NSUndoManagerNotifications
- (void)_didChangeDocument:(NSNotification *)notification {
  _itemsCache = nil;
  [self.tableView reloadData];
}

@end
