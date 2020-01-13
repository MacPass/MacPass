//
//  MPPluginHost.h
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
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

/* Notifications for loading plugins */
FOUNDATION_EXPORT NSString *const MPPluginHostWillLoadPluginNotification;
FOUNDATION_EXPORT NSString *const MPPluginHostDidLoadPluginNotification;

/* Keys used in info dictionary on notifications */
FOUNDATION_EXPORT NSString *const MPPluginHostPluginBundleIdentifiyerKey;

@class MPPlugin;
@class KPKEntry;
@protocol MPImportPlugin;
@protocol MPExportPlugin;
@protocol MPAutotypeWindowTitleResolverPlugin;

@interface MPPluginHost : NSObject

/* List of all plugins known to the plugin manager. Disabled plugins are also present! */
@property (readonly, copy) NSArray <MPPlugin __kindof*> *plugins;
@property (nonatomic, readonly, copy) NSString *version;

+ (instancetype)sharedHost;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)installPluginAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
- (BOOL)uninstallPlugin:(MPPlugin *)plugin error:(NSError *__autoreleasing *)error;
- (void)disablePlugin:(MPPlugin *)plugin;
- (void)enablePlugin:(MPPlugin *)plugin;

- (MPPlugin *)pluginWithBundleIdentifier:(NSString *)identifer;
- (NSArray *)avilableMenuItemsForEntries:(NSArray <KPKEntry *>*)entries;
@end

@interface MPPluginHost (MPImportExportPluginSupport)

@property (readonly, copy) NSArray <MPPlugin<MPImportPlugin> __kindof*> *importPlugins;
@property (readonly, copy) NSArray <MPPlugin<MPExportPlugin> __kindof*> *exportPlugins;

@end

@interface MPPluginHost (MPWindowTitleResolverSupport)

- (NSArray<MPPlugin<MPAutotypeWindowTitleResolverPlugin> __kindof*> *)windowTitleResolverForRunningApplication:(NSRunningApplication *)runningApplication;

@end
