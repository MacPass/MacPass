//
//  MPPluginEntryActionContext.h
//  MacPass
//
//  Created by Michael Starke on 15.02.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPPlugin;
@class KPKEntry;
@protocol MPEntryActionPlugin;

@interface MPPluginEntryActionContext : NSObject

@property (strong) MPPlugin<MPEntryActionPlugin> *plugin;
@property (copy) NSArray <KPKEntry *> *entries;

- (instancetype)initWithPlugin:(MPPlugin<MPEntryActionPlugin> *)plugin entries:(NSArray <KPKEntry *> *)entries NS_DESIGNATED_INITIALIZER;

@end
