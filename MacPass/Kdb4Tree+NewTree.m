//
//  Kdb4Tree+NewTree.m
//  MacPass
//
//  Created by Michael Starke on 21.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Tree+NewTree.h"

@implementation Kdb4Tree (NewTree)

+ (Kdb4Tree *)templateTree {
  NSDate *currentTime = [NSDate date];
  
  Kdb4Tree *tree = [[Kdb4Tree alloc] init];
  tree.generator = @"MacPass";
  tree.databaseName = @"";
  tree.databaseNameChanged = currentTime;
  tree.databaseDescription = @"";
  tree.databaseDescriptionChanged = currentTime;
  tree.defaultUserName = @"";
  tree.defaultUserNameChanged = currentTime;
  tree.maintenanceHistoryDays = 365;
  tree.color = @"";
  tree.masterKeyChanged = currentTime;
  tree.masterKeyChangeRec = -1;
  tree.masterKeyChangeForce = -1;
  tree.protectTitle = NO;
  tree.protectUserName = NO;
  tree.protectPassword = YES;
  tree.protectUrl = NO;
  tree.protectNotes = NO;
  tree.recycleBinEnabled = YES;
  tree.recycleBinUuid = [UUID nullUuid];
  tree.recycleBinChanged = currentTime;
  tree.entryTemplatesGroup = [UUID nullUuid];
  tree.entryTemplatesGroupChanged = currentTime;
  tree.historyMaxItems = 10;
  tree.historyMaxSize = 6 * 1024 * 1024; // 6 MB
  tree.lastSelectedGroup = [UUID nullUuid];
  tree.lastTopVisibleGroup = [UUID nullUuid];
  
  KdbGroup *parentGroup = [tree createGroup:nil];
  parentGroup.name = @"General";
  parentGroup.image = 48;
  tree.root = parentGroup;
  
  KdbGroup *group = [tree createGroup:parentGroup];
  group.name = @"Windows";
  group.image = 38;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = @"Network";
  group.image = 3;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = @"Internet";
  group.image = 1;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = @"eMail";
  group.image = 19;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = @"Homebanking";
  group.image = 37;
  [parentGroup addGroup:group];
  
  return tree;
}

@end
