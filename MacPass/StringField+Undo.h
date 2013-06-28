//
//  StringField+Undo.h
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Node.h"

APPKIT_EXTERN NSString *const MPStringFieldKeyUndoableKey;
APPKIT_EXTERN NSString *const MPStringFieldValueUndoableKey;

@interface StringField (Undo)


- (NSString *)keyUndoable;
- (NSString *)valueUndoable;

- (void)setKeyUndoable:(NSString *)key;
- (void)setValueUndoable:(NSString *)value;

@end
