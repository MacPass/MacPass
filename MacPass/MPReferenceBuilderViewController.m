//
//  MPReferenceBuilderViewController.m
//  MacPass
//
//  Created by Michael Starke on 05/12/14.
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

#import "MPReferenceBuilderViewController.h"

#import "KeePassKit/KeePassKit.h"

@interface MPReferenceBuilderViewController ()

@property (nonatomic, copy) NSString *searchString;

@end

@implementation MPReferenceBuilderViewController

- (NSString *)nibName {
  return @"ReferenceBuilderView";
}

- (void)viewDidLoad {
  self.searchKeyPopUpButton.menu = [self _allocateAttributeItemMenu:YES withTitle:NSLocalizedString(@"SEARCH_VALUE", "Search field for references lookup")];
  self.valuePopUpButton.menu = [self _allocateAttributeItemMenu:NO withTitle:NSLocalizedString(@"OUTPUT_VALUE", "Value field for reference lookup")];
  [self.searchStringTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(searchString)) options:nil];
  [self _updateReferenceString];
}

- (NSMenu *)_allocateAttributeItemMenu:(BOOL)allowCustomAttributes withTitle:(NSString *)title {
  NSMenu *menu = [[NSMenu alloc] init];
  /* first item is button label */
  [menu addItemWithTitle:NSLocalizedString(@"UUID","UUID reference item") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"TITLE","Title reference item") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"USERNAME","Username reference item") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"PASSWORD","Password reference item") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"URL","URL reference item") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"NOTES","Notes reference item") action:NULL keyEquivalent:@""];
  if(allowCustomAttributes) {
    [menu addItemWithTitle:NSLocalizedString(@"CUSTOM_ATTRIBUTE","Custom attribute reference item") action:NULL keyEquivalent:@""];
  }
  NSArray *keys = @[ kKPKReferenceUUIDKey, kKPKReferenceTitleKey, kKPKReferenceUsernameKey, kKPKReferencePasswordKey, kKPKReferenceURLKey, kKPKReferenceNotesKey, @"S" ];
  [menu.itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSMenuItem *item = (NSMenuItem *)obj;
    NSAssert(keys.count > idx, @"");
    item.representedObject = keys[idx];
  }];
  return menu;
}

- (void)setSearchString:(NSString *)searchString {
  if(![searchString isEqualToString:_searchString]) {
    _searchString = [searchString copy];
    [self _updateReferenceString];
  }
}

- (IBAction)updateReference:(id)sender {
  [self _updateReferenceString];
}

- (IBAction)updateKey:(id)sender {
  [self _updateReferenceString];
}

- (void)_updateReferenceString {
  NSString *key = self.searchKeyPopUpButton.selectedItem.representedObject;
  NSString *value = self.valuePopUpButton.selectedItem.representedObject;
  NSString *newValue = [[NSString alloc] initWithFormat:@"{REF:%@@%@:%@}", value, key, self.searchStringTextField.stringValue];
  self.referenceStringTextField.stringValue = newValue;
}
@end
