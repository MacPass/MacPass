//
//  KdbTree+MPAdditions.m
//  MacPass
//
//  Created by michael starke on 20.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbTree+MPAdditions.h"
#import "KdbGroup+MPTreeTools.h"

#import "NSMutableData+Base64.h"
#import "Kdb3Node.h"
#import "Kdb4Node.h"

@implementation KdbTree (MPAdditions)

- (NSArray *)allGroups {
  return [self.root childGroups];
}

- (NSArray *)allEntries {
  return [self.root childEntries];
}

@end
