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

#import "MPDocument.h"
#import "MPAutotypeContext.h"

#import "KPKNode.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "KPKAutotype.h"
#import "KPKWindowAssociation.h"

#import "MPSettingsHelper.h"

@implementation MPDocument (Autotype)

+ (BOOL)isCandidateForMalformedAutotype:(id)item {
  
  NSString *keystrokeSequence = @"";
  if([item isKindOfClass:[KPKEntry class]] && ![((KPKEntry *)item).autotype hasDefaultKeystrokeSequence]) {
    keystrokeSequence = ((KPKEntry *)item).autotype.defaultKeystrokeSequence;
  }
  else if( [item isKindOfClass:[KPKGroup class]] && ![item hasDefaultAutotypeSequence]) {
    keystrokeSequence = ((KPKGroup *)item).defaultAutoTypeSequence;
  }
  else if( [item isKindOfClass:[KPKWindowAssociation class]] && ![item hasDefaultKeystrokeSequence]){
    keystrokeSequence = ((KPKWindowAssociation *)item).keystrokeSequence;
  }
  /* if nothing is true, keystrokeSequence is nil an hence return is NO */
  return (NSOrderedSame == [@"{TAB}{USERNAME}{TAB}{PASSWORD}{ENTER}" compare:keystrokeSequence options:NSCaseInsensitiveSearch]);
}

- (NSArray *)autotypContextsForWindowTitle:(NSString *)windowTitle preferredEntry:(KPKEntry *)entry {
  if(!windowTitle) {
    return nil;
  }
  BOOL usePreferredEntry = (nil != entry);
  /* We might get a preferred entry from other documents, if so, stop searching and return */
  if(usePreferredEntry && entry.rootGroup != self.root) {
    return nil;
  }
  NSArray *autotypeEntries = usePreferredEntry ? [[NSArray alloc] initWithObjects:entry, nil] : [self.root autotypeableChildEntries];
  NSMutableArray *contexts = [[NSMutableArray alloc] initWithCapacity:MAX(1,ceil(autotypeEntries.count / 4.0))];
  
  BOOL matchTitle = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyAutotypeMatchTitle];
  BOOL matchURL = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyAutotypeMatchURL];
  BOOL matchHost = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyAutotypeMatchHost];
  BOOL matchTags = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyAutotypeMatchTags];
  
  MPAutotypeContext *context;
  for(KPKEntry *entry in autotypeEntries) {
    /* search in Autotype entries for match */
    KPKWindowAssociation *association = [entry.autotype windowAssociationMatchingWindowTitle:windowTitle];
    context = [[MPAutotypeContext alloc] initWithWindowAssociation:association];
    if(context.valid) {
      [contexts addObject:context];
      continue; // association did match
    }
    BOOL foundMatch = NO;
    /* Test for entry title in window title */
    if(matchTitle && !foundMatch) {
      foundMatch = [windowTitle rangeOfString:entry.title options:NSCaseInsensitiveSearch].length != 0 || [entry.title rangeOfString:windowTitle options:NSCaseInsensitiveSearch].length != 0;
    }
    /* test for URL */
    if(matchURL && !foundMatch) {
      foundMatch = [windowTitle rangeOfString:entry.url options:NSCaseInsensitiveSearch].length != 0;
    }
    /* test for host */
    if(matchHost && !foundMatch) {
      NSURL *url = [NSURL URLWithString:entry.url];
      foundMatch = [windowTitle rangeOfString:url.host options:NSCaseInsensitiveSearch].length != 0;
    }
    /* test for tags */
    if(matchTags && !foundMatch) {
      for(NSString *tag in entry.tags) {
        foundMatch = ([windowTitle rangeOfString:tag options:NSCaseInsensitiveSearch].length != 0);
        if(foundMatch) {
          break;
        }
      }
    }
    if(foundMatch) {
      context = [[MPAutotypeContext alloc] initWithDefaultSequenceForEntry:entry];
      if(context.valid) {
        [contexts addObject:context];
      }
    }
  }
  
  /* Fall back to preferred Entry if no match was found */
  if(usePreferredEntry && contexts.count == 0 ) {
    context = [[MPAutotypeContext alloc] initWithEntry:entry andSequence:entry.autotype.defaultKeystrokeSequence];
    if(context.valid) {
      [contexts addObject:context];
    }
  }
  return contexts;
}

- (BOOL)hasMalformedAutotypeItems {
  return [[self malformedAutotypeItems] count] > 0;
}

- (NSArray *)malformedAutotypeItems {
  NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1000];
  [self _flattenGroup:self.root toArray:items];
  NSPredicate *malformedPrediacte = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    return [MPDocument isCandidateForMalformedAutotype:evaluatedObject];
  }];
  NSArray *malformedItems = [items filteredArrayUsingPredicate:malformedPrediacte];
  return malformedItems;
}

- (void)_flattenGroup:(KPKGroup *)group toArray:(NSMutableArray *)array {
  [array addObject:group];
  for(KPKEntry *entry in group.entries) {
    [array addObject:entry];
    [array addObjectsFromArray:entry.autotype.associations];
  }
  for(KPKGroup *childGroup in group.groups) {
    [self _flattenGroup:childGroup toArray:array];
  }
}
@end
