//
//  MPWelcomeWindowViewController.m
//  MacPass
//
//  Created by Michael Starke on 28.09.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPWelcomeViewController.h"
#import "MPConstants.h"

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
  return MAX(1, NSDocumentController.sharedDocumentController.recentDocumentURLs.count);
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  NSArray<NSURL *> *recentURLS = NSDocumentController.sharedDocumentController.recentDocumentURLs;
  if(row > -1 && row < recentURLS.count) {
    NSURL *url = recentURLS[row];
    view.textField.enabled = YES;
    view.imageView.enabled = YES;
    view.textField.stringValue = url.lastPathComponent;
    view.imageView.image = [NSWorkspace.sharedWorkspace iconForFile:url.path];
  }
  else {
    view.textField.enabled = NO;
    view.imageView.enabled = NO;
    view.textField.stringValue = NSLocalizedString(@"WELCOME_WINDOW_NO_RECENT_DOCUMENTS", "Text displayed when no recent documents can be displayed in");
    view.imageView.image = [NSWorkspace.sharedWorkspace iconForFileType:MPKdbxDocumentUTI];
  }
  return view;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
  return (NSDocumentController.sharedDocumentController.recentDocumentURLs.count > 0);
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
