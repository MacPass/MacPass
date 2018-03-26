//
//  MPPluginEntryActionContext.m
//  MacPass
//
//  Created by Michael Starke on 15.02.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginEntryActionContext.h"

@implementation MPPluginEntryActionContext

- (instancetype)init {
  return [self initWithPlugin:nil entries:nil];
}

- (instancetype)initWithPlugin:(MPPlugin<MPEntryActionPlugin> *)plugin entries:(NSArray<KPKEntry *> *)entries {
  self = [super init];
  if(self) {
    _plugin = plugin;
    _entries = [entries copy];
  }
  return self;
}

@end
