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
#import "MPKeyTyper.h"

#import "MPSettingsHelper.h"

@interface MPAutotypeKeyPress ()
@property (copy) NSString *character;
@end

@implementation MPAutotypeKeyPress

- (instancetype)initWithModifiedKey:(MPModifiedKey)key {
  return [self _initWithModifiedKey:key text:nil];
}

- (instancetype)_initWithModifiedKey:(MPModifiedKey)key text:(NSString *)text {
  self = [super init];
  if(self) {
    _character = [text copy];
    _key = key;
  }
  return self;
}

- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask character:(NSString *)character {
  /* try to map the character */
  if(modiferMask) {
    MPModifiedKey mappedKey = [MPKeyMapper modifiedKeyForCharacter:character];
    if(mappedKey.keyCode == kMPUnknownKeyCode) {
      NSLog(@"Error. Unable to determine virtual key for character %@ to send with modifiers %llu.", character, modiferMask);
      self = nil;
    }
    else {
      mappedKey.modifier = modiferMask;
      self = [self _initWithModifiedKey:mappedKey text:nil];
    }
  }
  else {
    self = [self _initWithModifiedKey:MPMakeModifiedKey(0, 0) text:character];
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
  if(self.character) {
    [MPKeyTyper sendText:self.character];
  }
  else {
    [MPKeyTyper sendKey:self.key];
  }
}

- (BOOL)isValid {
  return YES;
  /* TODO test for actual validity of the command */
  //return ([self _transformKeyCode] != kMPUnknownKeyCode);
}

@end

