//
//  MPReferenceBuilderViewController.m
//  MacPass
//
//  Created by Michael Starke on 05/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPReferenceBuilderViewController.h"

@interface MPReferenceBuilderViewController ()

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
}

- (NSMenu *)_allocateAttributeItemMenu:(BOOL)allowCustomAttributes withTitle:(NSString *)title {
  NSMenu *menu = [[NSMenu alloc] init];
  /* first item is button label */
  [menu addItemWithTitle:title action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"UUID","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"TITLE","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"USERNAME","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"PASSWORD","") action:NULL keyEquivalent:@""];
  [menu addItemWithTitle:NSLocalizedString(@"URL","") action:NULL keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"NOTES","") action:NULL keyEquivalent:@""];
  if(allowCustomAttributes) {
    [menu addItemWithTitle:NSLocalizedString(@"CUSTOM_ATTRIBUTE","") action:NULL keyEquivalent:@""];
  }
  return menu;
}

@end
