//
//  NSString+MPComposedCharacterLength.h
//  MacPass
//
//  Created by Michael Starke on 03.05.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MPComposedCharacterAdditions)

@property (nonatomic, readonly) NSUInteger composedCharacterLength;
@property (nonatomic, readonly, copy) NSArray<NSValue *> *composedCharacterRanges; // NSArray of NSValues of NSRanges

- (NSString *)composedCharacterAtIndex:(NSUInteger)index;

@end
