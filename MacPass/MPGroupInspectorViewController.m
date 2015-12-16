//
//  MPGroupInspectorViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPGroupInspectorViewController.h"
#import "MPDocument.h"
#import "MPPasteBoardController.h"
#import "MPValueTransformerHelper.h"

#import "KeePassKit/KeePassKit.h"

#import "HNHUi/HNHUi.h"

@interface MPGroupInspectorViewController ()

//@property (nonatomic, weak) KPKGroup *group;
@property (strong) NSPopover *popover;
@property (strong) NSObjectController *groupController;

@end

@implementation MPGroupInspectorViewController

- (NSString *)nibName {
  return @"GroupInspectorView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _groupController = [[NSObjectController alloc] init];
  }
  return self;
}

- (void)awakeFromNib {
  HNHUIScrollView *scrollView = (HNHUIScrollView *)self.view;
  
  scrollView.actAsFlipped = NO;
  scrollView.showBottomShadow = NO;
  scrollView.hasVerticalRuler = YES;
  scrollView.drawsBackground = NO;
  scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  NSView *clipView = scrollView.contentView;
  
  scrollView.documentView = self.contentView;
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_contentView);
  [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
  [self.view layoutSubtreeIfNeeded];
  
  NSMenu *autotypeMenu = self.autotypePopupButton.menu;
  NSMenuItem *inheritAutotype = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"AUTOTYPE_INHERIT", "") action:NULL keyEquivalent:@""];
  inheritAutotype.tag = KPKInherit;
  NSMenuItem *enableAutotype = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"AUTOTYPE_YES", "") action:NULL keyEquivalent:@""];
  enableAutotype.tag = KPKInheritYES;
  NSMenuItem *disableAutotype = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"AUTOTYPE_NO", "") action:NULL keyEquivalent:@""];
  disableAutotype.tag = KPKInheritNO;
  
  [autotypeMenu addItem:inheritAutotype];
  [autotypeMenu addItem:enableAutotype];
  [autotypeMenu addItem:disableAutotype];
  
  NSMenu *searchMenu = self.searchPopupButton.menu;
  NSMenuItem *inheritSearch = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SEARCH_INHERIT", "") action:NULL keyEquivalent:@""];
  inheritSearch.tag = KPKInherit;
  NSMenuItem *includeInSearch = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SEARCH_YES", "") action:NULL keyEquivalent:@""];
  includeInSearch.tag = KPKInheritYES;
  NSMenuItem *excludeFromSearch = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SEARCH_NO", "") action:NULL keyEquivalent:@""];
  excludeFromSearch.tag = KPKInheritNO;
  
  [searchMenu addItem:inheritSearch];
  [searchMenu addItem:includeInSearch];
  [searchMenu addItem:excludeFromSearch];
  
  [self _establishBindings];
}

- (void)setupBindings:(MPDocument *)document {
  [self.groupController bind:NSContentObjectBinding toObject:document withKeyPath:NSStringFromSelector(@selector(selectedGroup)) options:nil];
}

- (void)_establishBindings {
  [self.titleTextField bind:NSValueBinding
                   toObject:self.groupController
                withKeyPath:[NSString stringWithFormat:@"%@.%@", NSContentBinding, NSStringFromSelector(@selector(title))]
                    options:@{NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", @"")}];
  [self.expiresCheckButton bind:NSValueBinding
                       toObject:self.groupController
                    withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSContentBinding, NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(expires))]
                        options:nil];
  [self.expiresCheckButton bind:NSTitleBinding
                       toObject:self.groupController
                    withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSContentBinding, NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(expirationDate))]
                        options:@{ NSValueTransformerNameBindingOption:MPExpiryDateValueTransformer }];
  [self.autotypePopupButton bind:NSSelectedTagBinding
                        toObject:self.groupController
                     withKeyPath:[NSString stringWithFormat:@"%@.%@", NSContentBinding, NSStringFromSelector(@selector(isAutoTypeEnabled))]
                         options:nil];
  [self.autotypeSequenceTextField bind:NSValueBinding
                              toObject:self.groupController
                           withKeyPath:[NSString stringWithFormat:@"%@.%@", NSContentBinding, NSStringFromSelector(@selector(defaultAutoTypeSequence))]
                               options:@{NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", @"")}];
  [self.searchPopupButton bind:NSSelectedTagBinding
                      toObject:self.groupController
                   withKeyPath:[NSString stringWithFormat:@"%@.%@", NSContentBinding, NSStringFromSelector(@selector(isSearchEnabled))]
                       options:nil];
}

@end
