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

#import "KPKGroup.h"

#import "HNHScrollView.h"
#import "HNHRoundedTextField.h"

@interface MPGroupInspectorViewController ()

@property (nonatomic, weak) KPKGroup *group;

@end

@implementation MPGroupInspectorViewController

- (id)init {
  return [self initWithNibName:@"GroupInspectorView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didLoadView {
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
  
  copyAction copyBlock = ^void(NSTextField *textField) {
    [[MPPasteBoardController defaultController] copyObjects:@[ textField.stringValue ]];
  };
  
  self.titleTextField.copyActionBlock = copyBlock;
}

- (void)setupBindings:(MPDocument *)document {
  [self bind:@"group" toObject:document withKeyPath:@"selectedGroup" options:nil];
}

- (void)setGroup:(KPKGroup *)group {
  if(_group != group) {
    _group = group;
    [self _updateBindings];
  }
}

- (void)_updateBindings {
  if(self.group) {
    [self.titleTextField bind:NSValueBinding toObject:self.group withKeyPath:@"name" options:nil];
    [self.notesTextView bind:NSValueBinding toObject:self.group withKeyPath:@"notes" options:nil];
    [self.expiresCheckButton bind:NSValueBinding toObject:self.group.timeInfo withKeyPath:@"expires" options:nil];
    [self.autotypePopupButton bind:NSSelectedTagBinding toObject:self.group withKeyPath:@"isAutoTypeEnabled" options:nil];
    [self.searchPopupButton bind:NSSelectedTagBinding toObject:self.group withKeyPath:@"isSearchEnabled" options:nil];
  }
  else {
    [self.titleTextField unbind:NSValueBinding];
    [self.notesTextView unbind:NSValueBinding];
    
    [self.expiresCheckButton unbind:NSValueBinding];
    [self.autotypePopupButton unbind:NSSelectedTagBinding];
    [self.searchPopupButton unbind:NSSelectedTagBinding];
  }
}

@end
