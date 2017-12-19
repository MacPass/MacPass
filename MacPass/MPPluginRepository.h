//
//  MPPluginRepository.h
//  MacPass
//
//  Created by Michael Starke on 04.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPPluginRespositoryItem : NSObject

@property (copy) NSString *name;
@property (copy) NSString *version;
@property (copy) NSString *descriptionText;
@property (copy) NSURL *sourceURL;
@property (copy) NSURL *downloadURL;
@property (readonly, nonatomic, getter=isVaid) BOOL valid;

+ (instancetype)pluginItemFromDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface MPPluginRepository : NSObject

@property (nonatomic, copy) NSArray<MPPluginRespositoryItem *> *availablePlugins;

+ (instancetype)sharedRespoitory;

@end
