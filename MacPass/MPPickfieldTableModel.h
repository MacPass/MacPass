//
//  MPPickfieldTableModel.h
//  MacPass
//
//  Created by Michael Starke on 28.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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

#import <Foundation/Foundation.h>

@class MPDocument;
@class KPKEntry;

@interface MPPickfieldTableModelRowItem : NSObject

@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *value;
@property (readonly) BOOL isProtected;
@property (readonly) BOOL isGroup;

+ (instancetype)groupItemWithName:(NSString *)name;
+ (instancetype)itemWithName:(NSString *)name value:(NSString *)value;
+ (instancetype)itemWithName:(NSString *)name protectedValue:(NSString *)value;

@end

@interface MPPickfieldTableModel : NSObject

@property (copy) NSArray<MPPickfieldTableModelRowItem *> *items;

- (instancetype)initWithEntry:(KPKEntry *)entry;
- (MPPickfieldTableModelRowItem *)itemAtIndex:(NSUInteger)index;

@end

