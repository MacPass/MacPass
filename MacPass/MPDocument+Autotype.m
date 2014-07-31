//
//  MPDocument+Autotype.m
//  MacPass
//
//  Created by Michael Starke on 01/11/13.
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

#import "MPDocument+Autotype.h"
#import "MPAutotypeContext.h"

#import "KPKGroup.h"
#import "KPKEntry.h"
#import "KPKAutotype.h"
#import "KPKWindowAssociation.h"

@implementation MPDocument (Autotype)

- (NSArray *)autotypContextsForWindowTitle:(NSString *)windowTitle {
  if(!windowTitle) {
    return nil;
  }
  NSArray *autotypeEntries = [self.root autotypeableChildEntries];
  NSMutableArray *contexts = [[NSMutableArray alloc] initWithCapacity:MAX(1,ceil([autotypeEntries count] / 4.0))];
  for(KPKEntry *entry in autotypeEntries) {
    /* Test for title */
    NSRange titleRange = [entry.title rangeOfString:windowTitle options:NSCaseInsensitiveSearch];
    MPAutotypeContext *context;
    if(titleRange.location != NSNotFound && titleRange.length != 0) {
      context = [[MPAutotypeContext alloc] initWithEntry:entry andSequence:entry.autotype.defaultKeystrokeSequence];
    }
    /* search in Autotype entries for match */
    else {
      KPKWindowAssociation *association = [entry.autotype windowAssociationMatchingWindowTitle:windowTitle];
      context = [[MPAutotypeContext alloc] initWithWindowAssociation:association];
    }
    if([context isValid]) {
      [contexts addObject:context];
    }
  }
  return contexts;
}

@end
