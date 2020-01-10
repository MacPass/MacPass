//
//  MPPlugin.h
//  MacPass
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class MPPluginHost;
@class KPKEntry;
@class KPKAttribute;
@class KPKTree;

FOUNDATION_EXPORT NSString *const MPPluginUnkownVersion;
FOUNDATION_EXPORT NSString *const MPPluginDescriptionInfoDictionaryKey;

@interface MPPlugin : NSObject

@property (copy, readonly) NSString *identifier;
@property (copy, readonly) NSString *name;
@property (nonatomic, copy, readonly, nullable) NSString *shortVersionString;
@property (nonatomic, copy, readonly) NSString *versionString;
@property (nonatomic, copy, readonly) NSString *localizedDescription;
@property (nonatomic, strong, readonly) NSBundle *bundle;


/**
 If your plugin needs initalization override this method but you have to call [super initWithPluginHost:]
 Otherwise your plugin might not get registered correctly

 @param host plugin host hosting the pluing - MacPass
 @return the plugin instance ready for use
 */
- (instancetype)initWithPluginHost:(MPPluginHost *)host NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)didLoadPlugin;

@end

#pragma mark Supported Plugin Protocolls

/*
 Adopting this protocolls allows for custom settings in the Plugin settings pane.
 MacPass will load your view controller and place it inside the settings window
 when a user has selected your plugin in the list
 */
@protocol MPPluginSettings <NSObject>

@required
@property (strong, readonly) NSViewController *settingsViewController;

@end

/*
 Adopt this protocoll if you plugin can extract window title information for a set of applications
 This way, MacPass might yield better results for autotype. Beware that his might break interoparbility
 */
@protocol MPAutotypeWindowTitleResolverPlugin <NSObject>
@required

- (BOOL)acceptsRunningApplication:(NSRunningApplication *)runningApplication;
- (NSString *)windowTitleForRunningApplication:(NSRunningApplication *)runningApplication;
@end


#pragma mark Proposed Plugin Protocolls

/*
 Adopt this protocoll if your plugin supports actions on entries.
 Actions will get listed in various places in menues.
 You should not set target nor actions since they will get stripped.
 MacPass will call you back via -[MPPlugin performActionForMenuItem:withEntries:]
 */
@protocol MPEntryActionPlugin <NSObject>
@required
- (NSArray<NSMenuItem *> *)menuItemsForEntries:(NSArray< KPKEntry *>*)entries;
- (void)performActionForMenuItem:(NSMenuItem *)item withEntries:(NSArray <KPKEntry *>*)entries;
@optional
- (BOOL)validateMenuItem:(NSMenuItem *)item forEntries:(NSArray<KPKEntry *>*)entries;
@end

@protocol MPCustomAttributePlugin <NSObject>
@required
/* Supply a list of attribute keys that will get suggested for autocompletion as well as added to the extend add for custom fields */
@property (nonatomic,copy) NSArray<NSString *>* attributeKeys;
/*
 For any attribute created with the special key the plugin will get called to offer a custom generation for the attributes value.
 You can e.g. show UI to help the user create a special format.

 If nil is returned, an empty value will be used.
 */
- (NSString *)initialValueForAttributeWithKey:(NSString *)key;
@end

@protocol MPImportPlugin <NSObject>
@required
/**
 Called by the Host to upate a menu item for importing.
 You are supposed to update the title to something meaningfull.
 target and action will get set by host, so do not rely on them
 
 @param item MenuItem that will be used to import via the plugin
 */
- (void)prepareImportMenuItem:(NSMenuItem *)item;
/**
 Called by the host when an import is about to happen.
 Update the panel to allow work for all the files and formats you can open.
 
 Host will simply run the panel with - beginSheetModalForWindow:completionHandler:
 and will call treeForRunningOpenPanel:withResponse: afterwards to handle the result.

 @param panel The open panel that will be displayed to the user for importing files
 */
- (void)prepareOpenPanel:(NSOpenPanel *)panel;
/**
 This will get called when the open panel is closed by the user.
 You should retrieve any results from the panel and act accordingly.
 
 If you need custom UI in the process, you can show them here.
 For example, if a CVS import might need user input on how to handle the parsed files this is the place to show it.

 @param panel The open panel used for selecting what file(s) to import
 @return The KPKTree constructed from the selected input file(s)
 */
- (nullable KPKTree *)treeForRunningOpenPanel:(NSOpenPanel *)panel;
@end

@protocol MPExportPlugin <NSObject>

@required
/**
 Called by the host to update a menu item for exporting.
 You are supposed to update the title to something meaningfull.
 Target and action will get set by host, so do not rely on them
 
 @param item MenuItem that will be used to export via the plugin
 */
- (void)prepareExportMenuItem:(NSMenuItem *)item;

/**
 Called by the host when an export is about to happen.
 Update the panel to work for all the files and formats you can export

 @param panel The panel used to select the export destination
 */
- (void)prepareSavePanel:(NSSavePanel *)panel;
/**
 This will get called when the save panel is closed by the user.
 You should retrieve any results from the panel and act accordingly.
 
 If you need custom UI in the process, you can show them here.
 For example, if a CSV export might need user input to configure its output this is the place to show it.
 
 @param tree The current tree to be exported
 @param panel The save panel that was used to specify the export destination
 */
- (void)exportTree:(KPKTree *)tree forRunningSavePanel:(NSSavePanel *)panel;

@end


#pragma mark Deprecated

@interface MPPlugin (Deprecated)

- (instancetype)initWithPluginManager:(id)manager;

@end

NS_ASSUME_NONNULL_END
