//
//  MPPluginRepositoryBrowserViewController.m
//  MacPass
//
//  Created by Michael Starke on 11.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepositoryBrowserViewController.h"
#import "MPPluginRepository.h"
#import "MPPluginRepositoryItem.h"

NSString *MPPluginBrowserColumnName = @"MPPluginBrowserColumnName";
NSString *MPPluginBrowserColumnCurrentVersion = @"MPPluginBrowserColumnCurrentVersion";
NSString *MPPluginBrowserColumnInstalledVersion = @"MPPluginBrowserColumnInstalledVersion";

@interface MPPluginRepositoryBrowserViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (copy) NSArray<MPPluginRepositoryItem *>* repositoryItems;
@property (strong) IBOutlet NSTableView *itemTable;

@end

@implementation MPPluginRepositoryBrowserViewController

- (NSNibName)nibName {
  return @"PluginRepositoryBrowserView";
}

- (void)viewDidLoad {
  
  self.itemTable.tableColumns[0].identifier = MPPluginBrowserColumnName;
  self.itemTable.tableColumns[1].identifier = MPPluginBrowserColumnCurrentVersion;
  self.itemTable.tableColumns[2].identifier = MPPluginBrowserColumnInstalledVersion;
  
  [super viewDidLoad];
  [self _refreshRepository];
}

- (void)refresh:(id)sender {
  [self _refreshRepository];
}

- (IBAction)closeBrowser:(id)sender {
  [self.presentingViewController dismissViewController:self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return self.repositoryItems.count > 0 ? 100 : 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

  MPPluginRepositoryItem *item = self.repositoryItems.firstObject;
  if([tableColumn.identifier isEqualToString:MPPluginBrowserColumnName]) {
    NSTableCellView *view = [tableView makeViewWithIdentifier:@"NameCellView" owner:self];
    view.textField.stringValue = item.name;
    return view;
  }
  if([tableColumn.identifier isEqualToString:MPPluginBrowserColumnCurrentVersion]) {
      NSTableCellView *view = [tableView makeViewWithIdentifier:@"CurrentVersionCellView" owner:self];
    view.textField.stringValue = item.currentVersion;
    return view;
  }
  NSTableCellView *view = [tableView makeViewWithIdentifier:@"InstalledVersionCellView" owner:self];
  view.textField.stringValue = item.descriptionText;
  return view;
  
}

- (void)_refreshRepository {
  [MPPluginRepository.defaultRepository fetchRepositoryDataCompletionHandler:^(NSArray<MPPluginRepositoryItem *> * _Nonnull availablePlugins) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.repositoryItems = availablePlugins;
      [self.itemTable reloadData];
    });
  }];
}


@end
