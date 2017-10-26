//
//  MPAutotypeCandidateSelectionViewController.m
//  MacPass
//
//  Created by Michael Starke on 26.10.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCandidateSelectionViewController.h"
#import "MPAutotypeContext.h"

#import <KeePassKit/KeePassKit.h>

@interface MPAutotypeCandidateSelectionViewController () <NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation MPAutotypeCandidateSelectionViewController

- (NSNibName)nibName {
  return @"AutotypeCandidateSelectionViewController";
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return self.candidates.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  MPAutotypeContext *context = self.candidates[row];
  view.textField.stringValue = context.entry.title;
  view.imageView.image = context.entry.icon.image;
  return view;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do view setup here.
}

@end
