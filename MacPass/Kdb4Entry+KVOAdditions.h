//
//  Kdb4Entry+KVOAdditions.h
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Node.h"

@interface Kdb4Entry (KVOAdditions)

- (NSUInteger)countOfStringFields;
- (StringField *)objectInStringFieldsAtIndex:(NSUInteger)index;
- (void)removeObjectFromStringFieldsAtIndex:(NSUInteger)anIndex;
- (void)insertObject:(StringField *)stringfield inStringFieldsAtIndex:(NSUInteger)anIndex;


@end
