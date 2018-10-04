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

@interface MPPlugin : NSObject

@property (copy, readonly) NSString *identifier;
@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *version;
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

@protocol MPPluginSettings <NSObject>

@required
@property (strong, readonly) NSViewController *settingsViewController;

@end

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

@protocol MPExportPluginViewController <NSObject>
@required
@property (nonatomic, copy) NSDictionary *exportOptions;
@end

@protocol MPExportPlugin <NSObject>
@required
/* Ideally supply a list of Formats supported. This format specifier is used when being called */
@property (nonatomic, copy) NSDictionary<NSString *, NSString *>* localizedSuportedFormats;
- (NSData *)dataForTree:(KPKTree *)tree withFormat:(NSString *)format options:(NSDictionary *)options;
@optional
- (NSViewController<MPExportPluginViewController> *)exportViewControllerForTree:(KPKTree *)tree withFormat:(NSString *)format;
@end


@interface MPPlugin (Deprecated)

- (instancetype)initWithPluginManager:(id)manager;

@end

NS_ASSUME_NONNULL_END
