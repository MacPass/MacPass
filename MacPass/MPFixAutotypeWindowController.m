//
//  MPFixAutotypeWindowController.m
//  MacPass
//
//  Created by Michael Starke on 26/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPFixAutotypeWindowController.h"
#import "MPDocument.h"
#import "KPKNode.h"
#import "KPKEntry.h"
#import "KPKGroup.h"
#import "KPKAutotype.h"

NSString *const kMPAutotypeCell = @"AutotypeCell";
NSString *const kMPTitleCell = @"TitleCell";
NSString *const kMPIsDefaultCell = @"IsDefaultCell";

@interface KPKGroup (Breadcrumb)

- (NSString *)breadcrumb;

@end

@implementation KPKGroup (Breadcrumb)

- (NSString *)breadcrumb {
  if(self.parent) {
    return [[self.parent breadcrumb] stringByAppendingFormat:@" > %@", self.name];
  }
  return self.name;
}

@end

@interface MPFixAutotypeWindowController () {
  NSMutableArray *_elements;
}

@end

@implementation MPFixAutotypeWindowController

- (instancetype)init {
  self = [super initWithWindowNibName:@"FixAutotypeWindow"];
  return self;
}

- (instancetype)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if (self) {
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
}

- (void)reset {
  _elements = nil;
  [self.tableView reloadData];
}


#pragma mark -
#pragma mark Actions

- (void)clearAutotype:(id)sender {
  
  MPDocument *document = [self document];
  [[document undoManager] beginUndoGrouping];
  NSIndexSet *indexes = [self.tableView selectedRowIndexes];
  MPFixAutotypeWindowController __weak *weakSelf = self;
  [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    id item = [weakSelf entriesAndGroups][idx];
    if([item respondsToSelector:@selector(defaultAutoTypeSequence)]) {
      [item setDefaultAutoTypeSequence:nil];
    }
    else {
      [item autotype].defaultKeystrokeSequence = nil;
    }
  }];
  [[document undoManager] endUndoGrouping];
  [[document undoManager] setActionName:@"Clear Autotype"];
  [self.tableView reloadDataForRowIndexes:indexes columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)]];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [[self entriesAndGroups] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  id node = [self entriesAndGroups][row];
  if([[tableColumn identifier] isEqualToString:kMPTitleCell]) {
    if( [node respondsToSelector:@selector(title)]) {
      return [node title];
    }
    return [node breadcrumb];
  }
  else if ([[tableColumn identifier] isEqualToString:kMPAutotypeCell]) {
    if([node respondsToSelector:@selector(defaultAutoTypeSequence)]) {
      return [node defaultAutoTypeSequence];
    }
    return [[node autotype] defaultKeystrokeSequence];
  }
  else if([[tableColumn identifier] isEqualToString:kMPIsDefaultCell]) {
    BOOL isDefault = NO;
    if([node respondsToSelector:@selector(hasDefaultAutotypeSequence)]) {
      isDefault = [node hasDefaultAutotypeSequence];
    }
    else {
      isDefault = [[node autotype] hasDefaultKeystrokeSequence];
    }
    return isDefault ? @"Yes" : @"No";
  }
  return nil;
}


- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  id item = [self entriesAndGroups][row];
  if([item respondsToSelector:@selector(defaultAutoTypeSequence)]) {
    [item setDefaultAutoTypeSequence:object];
  }
  else {
    [[item autotype] setDefaultKeystrokeSequence:object];
  }
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  return [[tableColumn identifier] isEqualToString:kMPAutotypeCell];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
  id item = [self entriesAndGroups][row];
  return [item isKindOfClass:[KPKGroup class]];
}

#pragma mark -
#pragma mark Data accessors

- (NSArray *)entriesAndGroups {
  if(nil == _elements) {
    _elements = [[NSMutableArray alloc] init];
    MPDocument *document = [self document];
    [self flattenGroup:document.root toArray:_elements];
  }
  return _elements;
}


- (void)flattenGroup:(KPKGroup *)group toArray:(NSMutableArray *)array {
  [array addObject:group];
  [array addObjectsFromArray:group.entries];
  for(KPKGroup *childGroup in group.groups) {
    [self flattenGroup:childGroup toArray:array];
  }
}


@end
