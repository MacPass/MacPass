//
//  MPPluginRepositoryItem.h
//  MacPass
//
//  Created by Michael Starke on 08.03.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPPluginVersionComparator;

@interface MPPluginRepositoryItem : NSObject

@property (copy,readonly, nullable) NSString *name;
@property (copy,readonly, nullable) NSString *currentVersion;
@property (copy,readonly, nullable) NSString *descriptionText;
@property (copy,readonly, nullable) NSURL *sourceURL;
@property (copy,readonly, nullable) NSURL *downloadURL;
@property (copy,readonly, nullable) NSString *bundleIdentifier;

@property (readonly, nonatomic, getter=isVaid) BOOL valid;

+ (instancetype)pluginItemFromDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isPluginVersionCompatibleWithHost:(NSString *)pluginVersion;

@end

NS_ASSUME_NONNULL_END
