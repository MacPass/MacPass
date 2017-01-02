//
//  MPPlugin.h
//  MacPass
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class MPPluginManager;

FOUNDATION_EXPORT NSString *const kMPPluginFileExtension;

@interface MPPlugin : NSObject

@property (copy, readonly) NSString *identifier;
@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *version;

- (instancetype)initWithPluginManager:(MPPluginManager *)manager NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)didLoadPlugin;
- (void)willUnloadPlugin;

@end

@protocol MPPluginSettings <NSObject>

@required
@property (strong, readonly) NSViewController *settingsViewController;

@end

@class KPKTree;

@protocol MPPluginExporting <NSObject>

@required
- (KPKTree *)importTreeAtURL:(NSURL *)url error:(NSError **)error;

@end

@protocol MPPluginImporting <NSObject>

@required
- (NSData *)dataForTree:(KPKTree *)tree error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END