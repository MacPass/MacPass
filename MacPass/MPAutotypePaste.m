//
//  MPAutotypePaste.m
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

#import "MPAutotypePaste.h"
#import "MPPasteBoardController.h"
#import "MPKeyTyper.h"

#import "KeePassKit/KeePassKit.h"

@interface MPAutotypePaste ()

@property (copy) NSString *pasteData;

@end

@implementation MPAutotypePaste

- (instancetype)initWithString:(NSString *)aString {
  self = [super init];
  if(self) {
    self.pasteData = aString;
  }
  return self;
}

- (NSString *)description {
  return [[NSString alloc] initWithFormat:@"%@ paste:%@", [self class], self.pasteData];
}

- (void)appendString:(NSString *)aString {
  self.pasteData = [self.pasteData stringByAppendingString:aString];
}

- (void)execute {
  if([self.pasteData length] > 0) {
    [MPPasteBoardController.defaultController stashObjects];
    [MPPasteBoardController.defaultController copyObjectsWithoutTimeout:@[self.pasteData]];
    [MPKeyTyper sendPaste];
    usleep(0.2 * NSEC_PER_MSEC); // on 10.10 we need to wait a bit before restoring the pasteboard contents
    [MPPasteBoardController.defaultController restoreObjects];
  }
}

- (BOOL)isValid {
  /* Pasting should always be valid */
  return YES;
}



@end
