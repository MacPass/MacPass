//
//  MPPickfieldTableModel.h
//  MacPass
//
//  Created by Michael Starke on 28.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPDocument;
@class KPKEntry;

@interface MPPickfieldTableModelRowItem : NSObject

@property (copy) NSString *name;
@property (copy) NSString *value;
@property BOOL isGroup;

+ (instancetype)groupItemWithName:(NSString *)name;
+ (instancetype)itemWithName:(NSString *)name value:(NSString *)value;

@end

@interface MPPickfieldTableModel : NSObject

@property (copy) NSArray<MPPickfieldTableModelRowItem *> *items;

- (instancetype)initWithEntry:(KPKEntry *)entry inDocument:(MPDocument *)document;
- (MPPickfieldTableModelRowItem *)itemAtIndex:(NSUInteger)index;

@end

