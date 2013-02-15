//
//  MPOutlineDataSource.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineDataSource.h"
#import "MPDatabaseController.h"
#import "MPDatabaseDocument.h"
#import "KdbLib.h"

@implementation MPOutlineDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  if(!item) {
    MPDatabaseController *dbController = [MPDatabaseController defaultController];
    return [[dbController.database.root groups] count];
  }
  if( [item isKindOfClass:[KdbGroup class]]) {
    KdbGroup *group = item;
    return  [[group groups] count];
  }
  return 0;
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  if(!item) {
    MPDatabaseController *dbController = [MPDatabaseController defaultController];
    return dbController.database.root;
  }
  if( [item isKindOfClass:[KdbGroup class]]) {
    KdbGroup *group = item;
    if( [[group groups] count] > index ) {
      return [group groups][index];
    }
  }
  return nil;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  if(!item) {
    return true;
  }
  return [item isKindOfClass:[KdbGroup class]];
}

@end
