//
//  MPWelcomeWindowViewController.m
//  MacPass
//
//  Created by Michael Starke on 28.09.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPWelcomeViewController.h"

@interface MPWelcomeViewController ()

@property (strong) IBOutlet NSTableView *tableView;

@end

@implementation MPWelcomeViewController

- (NSNibName)nibName {
  return @"WelcomeView";
}

- (void)viewWillAppear {
  [super viewWillAppear];
  [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return NSDocumentController.sharedDocumentController.recentDocumentURLs.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  NSURL *url = NSDocumentController.sharedDocumentController.recentDocumentURLs[row];
  view.textField.stringValue = url.lastPathComponent;
  view.imageView.image = [NSWorkspace.sharedWorkspace iconForFile:url.path];
  return view;
}

- (IBAction)openRecentURL:(id)sender {
  NSInteger clicked = self.tableView.clickedRow;
  NSArray <NSURL *> *recentURLS = NSDocumentController.sharedDocumentController.recentDocumentURLs;
  if(clicked > -1 && clicked < recentURLS.count) {
    [NSDocumentController.sharedDocumentController openDocumentWithContentsOfURL:recentURLS[clicked]
                                                                         display:YES
                                                               completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {}];
  }
}

@end
