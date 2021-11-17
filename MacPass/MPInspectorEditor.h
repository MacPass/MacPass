//
//  MPInspectorEditor.h
//  MacPass
//
//  Created by Michael Starke on 14.10.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The InpsectorEditor protocoll that should be implemented by editors used in the inspector
/// Individual editors shoudl adopt different APIs to accomodate their needs
/// The preferred way to set model data is to use the representedObject
@protocol MPInspectorEditor <NSObject>

@required
@property (nonatomic) BOOL isEditor;

@end

NS_ASSUME_NONNULL_END
