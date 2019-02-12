//
//  MPAutotypeClear.m
//  MacPass
//
//  Created by Michael Starke on 20/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
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

#import "MPAutotypeClear.h"
#import "MPKeyMapper.h"
#import "MPKeyTyper.h"

#import <Carbon/Carbon.h>

@implementation MPAutotypeClear

- (NSString *)description {
  return self.class.description;
}

- (void)execute {
  MPModifiedKey key = [MPKeyMapper modifiedKeyForCharacter:@"a"];
  if(key.keyCode == kMPUnknownKeyCode) {
    NSLog(@"Unable to generate key code for 'A'");
    return;
  }
  [MPKeyTyper sendKey:MPMakeModifiedKey(kCGEventFlagMaskCommand, key.keyCode)];
  [MPKeyTyper sendKey:MPMakeModifiedKey(0, kVK_Delete)];
}

@end
