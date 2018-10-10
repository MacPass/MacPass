//
//  MPPluginVersion.h
//  MacPass
//
//  Created by Michael Starke on 05.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *MPPluginVersionWildcard;

@interface MPPluginVersion : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *versionString;
@property (nonatomic, copy, readonly) NSString *mayorVersion;
@property (nonatomic, copy, readonly) NSString *minorVersion;
@property (nonatomic, copy, readonly) NSString *patchVersion;

+ (instancetype)versionWithVersionString:(NSString *)versionString;

- (instancetype)initWithVersionString:(NSString *)versionString NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (NSComparisonResult)compare:(MPPluginVersion *)version;

@end

NS_ASSUME_NONNULL_END
