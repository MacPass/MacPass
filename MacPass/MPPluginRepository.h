//
//  MPPluginRepository.h
//  MacPass
//
//  Created by Michael Starke on 04.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

@import Foundation;

@class MPPluginRepositoryItem;

@interface MPPluginRepository : NSObject

@property (class, strong, readonly) MPPluginRepository *defaultRepository;
@property (nonatomic, copy) NSArray<MPPluginRepositoryItem *> *availablePlugins;


@end
