//
//  MPInspectorEditor.h
//  MacPass
//
//  Created by Michael Starke on 14.10.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KPKAttribute;
@class KPKEntry;
@class KPKTimeInfo;
@class KPKNode;

NS_ASSUME_NONNULL_BEGIN

/// The InpsectorEditor protocoll that should be implemented by editors used in the inspector
/// Individual editors shoudl adopt different APIs to accomodate their needs
/// The preferred way to set model data is to use the representedObject
@protocol MPInspectorEditor <NSObject>
@required
@property (nonatomic) BOOL isEditor;
- (void)commitChanges;
@end

/// NodeInspectorEditors require the represented object to be a KPKNode
@protocol KPKNodeInspectorEditor <MPInspectorEditor>
@required
@property (nonatomic, nullable, readonly, strong) KPKNode *representedNode;
@end

/// EntryInspectorEditors require the represented object to be a KPKEnty
@protocol MPEntryInspectorEditor <MPInspectorEditor>
@required
@property (nonatomic, nullable, readonly, strong) KPKEntry *representedEntry;
@end

/// AttributeInspectorEditors require the represented object to be a KPKAttribute
@protocol MPAttributeInspectorEditor <MPInspectorEditor>
@required
@property (nonatomic, nullable, readonly, strong) KPKAttribute *representedAttribute;
@end

/// TimeInfoInpspectorEditors require the represented object to be a KPKTimeInfo
@protocol MPTimeInfoInpspectorEditor <MPInspectorEditor>
@required
@property (nonatomic, nullable, readonly, strong) KPKTimeInfo *representedTimeInfo;
@end

NS_ASSUME_NONNULL_END
