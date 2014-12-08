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

#import "KPKGroup.h"
#import "KPKTimeInfo.h"

#import "HNHScrollView.h"
#import "HNHRoundedTextField.h"


@interface MPGroupInspectorViewController ()

@property (nonatomic, weak) KPKGroup *group;
@property (strong) NSPopover *popover;

@end

@implementation MPGroupInspectorViewController

- (NSString *)nibName {
  return @"GroupInspectorView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)awakeFromNib {
  HNHScrollView *scrollView = (HNHScrollView *)[self view];
  
  scrollView.actAsFlipped = NO;
  scrollView.showBottomShadow = NO;
  [scrollView setHasVerticalScroller:YES];
  [scrollView setDrawsBackground:NO];
  [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
  NSView *clipView = [scrollView contentView];
  
  [scrollView setDocumentView:self.contentView];
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_contentView);
  [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
  [[self view] layoutSubtreeIfNeeded];
  
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

  /*
   void(^copyBlock)(NSTextField *textField) = ^void(NSTextField *textField) {
   [[MPPasteBoardController defaultController] copyObjects:@[ textField.stringValue ]];
   };
   
   self.titleTextField.copyActionBlock = copyBlock;
   */
}

- (void)setupBindings:(MPDocument *)document {
  [self bind:NSStringFromSelector(@selector(group)) toObject:document withKeyPath:NSStringFromSelector(@selector(selectedGroup)) options:nil];
}

- (void)setGroup:(KPKGroup *)group {
  if(_group != group) {
    _group = group;
    [self _updateBindings];
  }
}

- (void)_updateBindings {
  if(self.group) {
    [self.titleTextField bind:NSValueBinding toObject:self.group withKeyPath:NSStringFromSelector(@selector(name)) options:nil];
    [self.expiresCheckButton bind:NSValueBinding toObject:self.group.timeInfo withKeyPath:NSStringFromSelector(@selector(expires)) options:nil];
    [self.expiresCheckButton bind:NSTitleBinding toObject:self.group.timeInfo withKeyPath:NSStringFromSelector(@selector(expiryTime)) options:@{ NSValueTransformerNameBindingOption:MPExpiryDateValueTransformer }];
    [self.autotypePopupButton bind:NSSelectedTagBinding toObject:self.group withKeyPath:NSStringFromSelector(@selector(isAutoTypeEnabled)) options:nil];
    [self.autotypeSequenceTextField bind:NSValueBinding toObject:self.group withKeyPath:NSStringFromSelector(@selector(defaultAutoTypeSequence)) options:nil];
    [self.searchPopupButton bind:NSSelectedTagBinding toObject:self.group withKeyPath:NSStringFromSelector(@selector(isSearchEnabled)) options:nil];
  }
  else {
    [self.titleTextField unbind:NSValueBinding];
    [self.expiresCheckButton unbind:NSValueBinding];
    [self.expiresCheckButton unbind:NSTitleBinding];
    [self.expiresCheckButton setTitle:NSLocalizedString(@"EXPIRES", "")];
    [self.searchPopupButton unbind:NSSelectedTagBinding];
    [self.autotypePopupButton unbind:NSSelectedTagBinding];
    [self.autotypeSequenceTextField unbind:NSValueBinding];
  }
}

@end
