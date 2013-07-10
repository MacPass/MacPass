//
//  Kdb3Tree+NewTree.m
//  MacPass
//
//  Created by Michael Starke on 21.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb3Tree+NewTree.h"

@implementation Kdb3Tree (NewTree)

+ (Kdb3Tree *)templateTree {
  Kdb3Tree *tree = [[Kdb3Tree alloc] init];
  
  Kdb3Group *rootGroup = [[Kdb3Group alloc] init];
  rootGroup.name = @"%ROOT%";
  tree.root = rootGroup;
  
  KdbGroup *parentGroup = [tree createGroup:rootGroup];
  parentGroup.name = NSLocalizedString(@"GENERAL", "General");
  parentGroup.image = 48;
  [rootGroup addGroup:parentGroup];
  
  KdbGroup *group = [tree createGroup:parentGroup];
  group.name = NSLocalizedString(@"WINDOWS", "Windows");
  group.image = 38;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = NSLocalizedString(@"NETWORK", "Network");
  group.image = 3;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = NSLocalizedString(@"INTERNET", "Internet");
  group.image = 1;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = NSLocalizedString(@"EMAIL", "EMail");
  group.image = 19;
  [parentGroup addGroup:group];
  
  group = [tree createGroup:parentGroup];
  group.name = NSLocalizedString(@"HOMEBANKING", "Homebanking");
  group.image = 37;
  [parentGroup addGroup:group];
  

  return tree;
}

@end
