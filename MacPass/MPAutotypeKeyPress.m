//
//  MPAutotypeSpecialKey.m
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

- (instancetype)initWithModifiedKey:(MPModifiedKey)key {
  self = [super init];
  if(self) {
    _key = key;
    _key.modifier = _updateModifierMaskForCurrentDefaults(_key.modifier);
  }
  return self;
}
- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask keyCode:(CGKeyCode)code {
  self = [self initWithModifiedKey:MPMakeModifiedKey(modiferMask, code)];
  return self;
}

- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask character:(NSString *)character {
  MPModifiedKey mappedKey = [MPKeyMapper modifiedKeyForCharacter:character];
  if(mappedKey.keyCode == kMPUnknownKeyCode) {
    self = nil;
  }
  else {
    if(mappedKey.modifier && (modiferMask != mappedKey.modifier)) {
      NSLog(@"Supplied modifiers for character %@ do not match required modifiers", character);
    }
    self = [self initWithModifierMask:modiferMask keyCode:mappedKey.keyCode];
  }
  return self;
}

- (NSString *)description {
  return [[NSString alloc] initWithFormat:@"%@: modifierMaks:%llu keyCode:%d", [self class], self.key.modifier, self.key.keyCode];
}

- (void)execute {
  if(![self isValid]) {
    return; // no valid command. Stop.
  }
  //CGKeyCode mappedKey = [self _transformKeyCode];
  [self sendPressKey:self.key];
}

- (BOOL)isValid {
  return YES;
  /* TODO test for actual validity of the command */
  //return ([self _transformKeyCode] != kMPUnknownKeyCode);
}

@end
