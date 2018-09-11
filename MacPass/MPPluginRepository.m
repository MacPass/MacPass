//
//  MPPluginRepository.m
//  MacPass
//
//  Created by Michael Starke on 04.12.17.
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

#import "MPPluginRepository.h"
#import "MPConstants.h"
#import "MPPluginRepositoryItem.h"

@implementation MPPluginRepository

@dynamic availablePlugins;

+ (instancetype)defaultRepository {
  static MPPluginRepository *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPPluginRepository alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  return self;
}

- (NSArray<MPPluginRepositoryItem *> *)availablePlugins {
  NSString *urlString = NSBundle.mainBundle.infoDictionary[MPBundlePluginRepositoryURLKey];
  if(!urlString) {
    return @[];
  }
  NSURL *jsonURL = [NSURL URLWithString:urlString];
  if(!jsonURL) {
    return @[];
  }
  NSError *error;
  NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:0 error:&error];
  if(!jsonData) {
    return @[];
  }
  id jsonRoot = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  if(!jsonRoot || ![jsonRoot isKindOfClass:NSArray.class]) {
    return @[];
  }
  NSMutableArray *items = [[NSMutableArray alloc] init];
  for(id item in jsonRoot) {
    if(![item isKindOfClass:NSDictionary.class]) {
      continue;
    }
    MPPluginRepositoryItem *pluginItem = [MPPluginRepositoryItem pluginItemFromDictionary:item];
    if(pluginItem.isVaid) {
      [items addObject:pluginItem];
    }
  }
  return [items copy];
}

@end
