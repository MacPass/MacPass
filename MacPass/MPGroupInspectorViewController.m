//
//  MPGroupInspectorViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPGroupInspectorViewController.h"
#import "MPDocument.h"

#import "Kdb.h"
#import "Kdb4Node.h"

#import "HNHScrollView.h"

@interface MPGroupInspectorViewController ()

@property (nonatomic, weak) KdbGroup *group;

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
}

- (void)setupBindings:(MPDocument *)document {
  [self bind:@"group" toObject:document withKeyPath:@"selectedGroup" options:nil];
}

- (void)setGroup:(KdbGroup *)group {
  if(_group != group) {
    _group = group;
    [self _updateBindings];
  }
}

- (void)_updateBindings {
  if(self.group) {
    [self.titleTextField bind:NSValueBinding toObject:self.group withKeyPath:@"name" options:nil];
    if([self.group respondsToSelector:@selector(notes:)]) {
      [self.notesTextView bind:NSValueBinding toObject:self.group withKeyPath:@"notes" options:nil];
    }
    else {
      [self.notesTextView unbind:NSValueBinding];
      [self.notesTextView setString:@""];
    }
  }
  else {
    [self.titleTextField unbind:NSValueBinding];
    [self.notesTextView unbind:NSValueBinding];
  }
}

@end
