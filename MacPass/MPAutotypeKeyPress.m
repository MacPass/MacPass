//
//  MPAutotypeSpecialKey.m
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeKeyPress.h"
#import "MPFlagsHelper.h"
#import "MPKeyMapper.h"

#import "MPSettingsHelper.h"

@implementation MPAutotypeKeyPress

static CGEventFlags _updateModifierMaskForCurrentDefaults(CGEventFlags modifiers) {
  BOOL sendCommand = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeySendCommandForControlKey];
  if(sendCommand && MPIsFlagSetInOptions(kCGEventFlagMaskControl, modifiers)) {
    return (modifiers ^ kCGEventFlagMaskControl) | kCGEventFlagMaskCommand;
  }
  return modifiers;
}

- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask keyCode:(CGKeyCode)code {
  self = [super init];
  if(self) {
    _modifierMask = _updateModifierMaskForCurrentDefaults(modiferMask);
    _keyCode = code;
  }
  return self;
}

- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask character:(NSString *)character {
  CGKeyCode mappedKey = [MPKeyMapper keyCodeForCharacter:character];
  if(mappedKey == kMPUnknownKeyCode) {
    self = nil;
  }
  else {
    self = [self initWithModifierMask:modiferMask keyCode:mappedKey];
  }
  return self;
}

- (NSString *)description {
  return [[NSString alloc] initWithFormat:@"%@: modifierMaks:%llu keyCode:%d", [self class], self.modifierMask, self.keyCode];
}

- (void)execute {
  if(![self isValid]) {
    return; // no valid command. Stop.
  }
  //CGKeyCode mappedKey = [self _transformKeyCode];
  [self sendPressKey:self.keyCode modifierFlags:self.modifierMask];
}

- (BOOL)isValid {
  return YES;
  /* TODO test for actual validity of the command */
  //return ([self _transformKeyCode] != kMPUnknownKeyCode);
}

- (CGKeyCode)_transformKeyCode {
  NSString *key = [MPKeyMapper stringForKey:self.keyCode];
  return [MPKeyMapper keyCodeForCharacter:key];
}

@end
