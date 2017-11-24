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
@class MPAutotypeCommand;
@class KPKEntry;

FOUNDATION_EXPORT NSString *const kMPPluginFileExtension;

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

/* Adopt this protocoll if you plugin supplied additinal autotype commands */
@protocol MPAutotypePlugin <NSObject>
@required
/**
 Returns an array of string of commands supported by this pluing. Leave out enclosing curly brackets!
 E.g. if you support {FOO} and {BAR} you will return @[ @"FOO", @"BAR" ]. The autotype system is case insenstivie.
 */
@property (nonatomic,copy) NSArray <NSString *> *commandStrings;
/**
 Will be called by the plugin host to generate autotype commands for the corresponding string.
 Command strings are considered case insensitive but mostly will be used in upper case.
 You should therefore compare case insensitive.

 @param commandString The command string without any enclosing curly brackets. The string is normalized to upper cased.
 @param entry The entry for which the command will be used
 @return a command for the supplied string, return nil if parsing fails or an unsupported command is supplied
 */
- (MPAutotypeCommand * _Nullable)commandForString:(NSString *)commandString entry:(KPKEntry *)entry;
@end

/*
 Adopt this protocoll if your plugin supports actions on entries.
 Actions will get listed in various places in menues. You should shoudl supply a valid menu item
 that is wired up with the correct target and action. Since there's responder chain resolving involved
 as well as a
 */
@protocol MPEntryActionPlugin <NSObject>
@optional
- (NSMenuItem * _Nullable)menuItemForEntry;
@end

@protocol MPCustomAttributePlugin <NSObject>
@optional
/* Supply a list of attribute keys that will get suggested for autocompletion as well as added to the extend add for custom fields */
@property (nonatomic,copy) NSArray<NSString *>* attributeKeys;
@end

@interface MPPlugin (Deprecated)

- (instancetype)initWithPluginManager:(id)manager;

@end

NS_ASSUME_NONNULL_END
