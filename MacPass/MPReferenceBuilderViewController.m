//
//  MPReferenceBuilderViewController.m
//  MacPass
//
//  Created by Michael Starke on 05/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPReferenceBuilderViewController.h"

@interface MPReferenceBuilderViewController ()

@property (nonatomic, copy) NSString *searchString;

@end

@implementation MPReferenceBuilderViewController

- (NSString *)nibName {
  return @"ReferenceBuilderView";
}

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//  if(self) {
//  }
//  return self;
//}

- (void)didLoadView {
  [self.searchKeyPopUpButton setMenu:[self _allocateAttributeItemMenu:YES withTitle:NSLocalizedString(@"SEARCH_VALUE", "")]];
  [self.valuePopUpButton setMenu:[self _allocateAttributeItemMenu:NO withTitle:NSLocalizedString(@"OUTPUT_VALUE", "")]];
  [self.searchStringTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(searchString)) options:nil];
  [self _updateReferenceString];
}

- (NSMenu *)_allocateAttributeItemMenu:(BOOL)allowCustomAttributes withTitle:(NSString *)title {
  NSMenu *menu = [[NSMenu alloc] init];
  /* first item is button label */
  //[menu addItemWithTitle:title action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"UUID","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"TITLE","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"USERNAME","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"PASSWORD","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"URL","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"NOTES","") action:NULL keyEquivalent:@""];
  if(allowCustomAttributes) {
    [menu addItemWithTitle:NSLocalizedString(@"CUSTOM_ATTRIBUTE","") action:NULL keyEquivalent:@""];
  }
  NSArray *keys = @[ @"I", @"T", @"U", @"P", @"A", @"N", @"S" ];
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
