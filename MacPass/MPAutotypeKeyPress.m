//
//  MPAutotypeSpecialKey.m
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeKeyPress.h"
#import "MPKeyMapper.h"

@implementation MPAutotypeKeyPress

- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask keyCode:(CGKeyCode)code {
  self = [super init];
  if(self) {
    _modifierMask = modiferMask;
    _keyCode = code;
  }
  return self;
}

- (void)execute {
  if(![self isValid]) {
    return; // no valid command. Stop.
  }
  CGKeyCode mappedKey = [self _transformKeyCode];
  [self sendPressKey:mappedKey modifierFlags:self.modifierMask];
}

- (BOOL)isValid {
  return ([self _transformKeyCode] != kMPUnknownKeyCode);
}

- (CGKeyCode)_transformKeyCode {
  NSString *key = [MPKeyMapper stringForKey:self.keyCode];
  return [MPKeyMapper keyCodeForCharacter:key];
}

@end
