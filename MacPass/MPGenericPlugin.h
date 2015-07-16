//
//  MPGenericPlugin.h
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPPluginManager

@protocol MPGenericPlugin <NSObject>

@required
@property (readonly) NSString *name;
@property (readonly) NSString *version;
@property (readonly) NSInteger *versionNumber;

- (instancetype)initWithPluginManager:(MPPluginManager *)manager;

@optional
- (void)manager:(MPPluginManager *)manager willAddNode:(KPKNode *)node;
- (void)manager:(MPPluginManager *)manager didAddNode(KPKNode *)node;
- (void)manager:(MPPluginManager *)manager willRemoveNode:(KPKNode *)node;
- (void)manager:(MPPluginManager *)manager didRemoveNode:(KPKNode *)node;

@end
