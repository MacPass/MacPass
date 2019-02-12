//
//  MPPluginRepository.h
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

NS_ASSUME_NONNULL_BEGIN

@import Foundation;

FOUNDATION_EXTERN NSString *const MPPluginRepositoryDidUpdateAvailablePluginsNotification;

@class MPPluginRepositoryItem;

@interface MPPluginRepository : NSObject

@property (class, strong, readonly) MPPluginRepository *defaultRepository;
@property (readonly, copy) NSDate *updatedAt;
@property (readonly) BOOL isInitialized;
/*
 this property is set asynchronously, to make sure, you receive valid data,
 register to MPPluginRepositoryDidUpdateAvailablePlugsinNotification and access
 availablePlugins after you received at least on notification
 */
@property (nonatomic, copy, readonly) NSArray<MPPluginRepositoryItem *> *availablePlugins;

@end

NS_ASSUME_NONNULL_END
