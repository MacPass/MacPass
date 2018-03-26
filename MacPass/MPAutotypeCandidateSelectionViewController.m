//
//  MPAutotypeCandidateSelectionViewController.m
//  MacPass
//
//  Created by Michael Starke on 26.10.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCandidateSelectionViewController.h"
#import "MPAutotypeContext.h"
#import "MPAutotypeDaemon.h"

#import "KPKNode+IconImage.h"

#import <KeePassKit/KeePassKit.h>

@interface MPAutotypeCandidateSelectionViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSButton *selectAutotypeContextButton;
@property (weak) IBOutlet NSTableView *contextTableView;

@end

@implementation MPAutotypeCandidateSelectionViewController

- (NSString *)nibName {
  return @"AutotypeCandidateSelectionView";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.selectAutotypeContextButton.enabled = NO;
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return self.candidates.count;
}

#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  MPAutotypeContext *context = self.candidates[row];
  NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", context.entry.title, context.maskedEvaluatedCommand]];
  [string setAttributes:@{NSForegroundColorAttributeName: NSColor.disabledControlTextColor} range:NSMakeRange(context.entry.title.length + 1, context.maskedEvaluatedCommand.length)];
  view.textField.attributedStringValue = string;
  view.imageView.image = context.entry.iconImage;
  return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *tableView = notification.object;
  if(tableView != self.contextTableView) {
    return;
  }
  self.selectAutotypeContextButton.enabled = (self.contextTableView.selectedRow != -1);
}

#pragma mark Actions
- (void)selectAutotypeContext:(id)sender {
  NSInteger selectedRow = self.contextTableView.selectedRow;
  if(selectedRow >= 0 && selectedRow < self.candidates.count) {
    [[MPAutotypeDaemon defaultDaemon] selectAutotypeCandiate:self.candidates[selectedRow]];
  }
  else {
    [self cancelSelection:sender]; // cancel since the selection was invalid!
  }
}

- (void)cancelSelection:(id)sender {
  [[MPAutotypeDaemon defaultDaemon] cancelAutotypeCandidateSelection];
}


@end
