//
//  KPKEntry+MPTags.m
//  MacPass
//
//  Created by Michael Starke on 20.03.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "KPKEntry+MPTags.h"

#import <AppKit/AppKit.h>


@implementation KPKEntry (MPTags)

+ (NSSet<NSString *> *)keyPathsForValuesAffectingTagsString {
  return [NSSet setWithObject:NSStringFromSelector(@selector(tags))];
}

- (NSString *)tagsString {
  return [self.tags componentsJoinedByString:@" "];
}

@end
