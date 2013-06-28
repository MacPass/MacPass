//
//  StringField+Undo.m
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "StringField+Undo.h"

NSString *const MPStringFieldKeyUndoableKey   = @"keyUndoable";
NSString *const MPStringFieldValueUndoableKey = @"valueUndoable";

@implementation StringField (Undo)

- (NSUndoManager *)undoManager {
  return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (NSString *)keyUndoable {
  return self.key;
}

- (NSString *)valueUndoable {
  return self.value;
}

- (void)setKeyUndoable:(NSString *)key {
  if(![self.key isEqualToString:key]) {
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setKeyUndoable:) object:self.key];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_STRINGFILED_KEY", @"Set StringField key")];
    self.key = key;
  }
}

- (void)setValueUndoable:(NSString *)value {
  if(![self.value isEqualToString:value]) {
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setValueUndoable:) object:self.value];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_STRINGFIELD_VALUE", @"Set StringField value")];
    self.value = value;
  }
}

@end
