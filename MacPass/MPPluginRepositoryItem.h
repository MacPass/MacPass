//
//  MPPluginRepositoryItem.h
//  MacPass
//
//  Created by Michael Starke on 08.03.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPPluginRepositoryItem : NSObject

@property (copy,readonly) NSString *name;
@property (copy,readonly) NSString *currentVersion;
@property (copy,readonly) NSString *descriptionText;
@property (copy,readonly) NSURL *sourceURL;
@property (copy,readonly) NSURL *downloadURL;
@property (copy,readonly) NSURL *bundleIdentifier;

@property (readonly, nonatomic, getter=isVaid) BOOL valid;

+ (instancetype)pluginItemFromDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
