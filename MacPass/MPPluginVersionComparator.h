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

@interface MPPluginVersionComparator : NSObject

typedef NS_ENUM(NSUInteger, MPVersionCharacterType ) {
  kMPVersionCharacterTypeWildcard,
  kMPVersionCharacterTypeSeparator,
  kMPVersionCharacterTypeNumeric,
  kMPVersionCharacterTypeString
};

+ (MPVersionCharacterType)typeOfCharacter:(NSString *)character;
+ (NSArray<NSString *> *)splitVersionString:(NSString *)versionString;
+ (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB;

@end

NS_ASSUME_NONNULL_END
