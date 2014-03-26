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

@property (weak) NSTableView *tableView;

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
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  
  self.tableView = tableView;
  
  return [[self entriesAndGroups] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  
  self.tableView = tableView;
  id node = [self entriesAndGroups][row];
  if([[tableColumn identifier] isEqualToString:@"TitleCell"]) {
    if( [node respondsToSelector:@selector(title)]) {
      return [node title];
    }
    return [node breadcrumb];
  }
  else if ([[tableColumn identifier] isEqualToString:@"AutotypeCell"]) {
    if([node respondsToSelector:@selector(defaultAutoTypeSequence)]) {
      return [node defaultAutoTypeSequence];
    }
    return [[node autotype] defaultKeystrokeSequence];
  }
  else if([[tableColumn identifier] isEqualToString:@"IsDefaultCell"]) {
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

#pragma mark -
#pragma mark NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
  id item = [self entriesAndGroups][row];
  return [item isKindOfClass:[KPKGroup class]];
}

#pragma mark -
#pragma mark Data accessors

- (NSArray *)entriesAndGroups {
  if(nil == _elements) {
    NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
    _elements = [[NSMutableArray alloc] init];
    for(MPDocument *document in documents) {
      if(!document.root) {
        continue;
      }
      KPKGroup *group = document.root;
      [self flattenGroup:group toArray:_elements];
    }
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
