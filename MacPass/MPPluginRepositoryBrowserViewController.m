//
//  MPPluginRepositoryBrowserViewController.m
//  MacPass
//
//  Created by Michael Starke on 11.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepositoryBrowserViewController.h"
#import "MPPlugin.h"
#import "MPPluginHost.h"
#import "MPPluginRepository.h"
#import "MPPluginRepositoryItem.h"
#import "MPPluginBrowserTableCellView.h"

@interface MPPluginRepositoryBrowserViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (copy) NSArray<MPPluginRepositoryItem *>* repositoryItems;
@property (strong) IBOutlet NSTableView *itemTable;

@end

@implementation MPPluginRepositoryBrowserViewController

- (NSNibName)nibName {
  return @"PluginRepositoryBrowserView";
}

- (void)viewDidLoad {
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
  MPPluginBrowserTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  MPPluginRepositoryItem *item = self.repositoryItems.firstObject;
  view.textField.stringValue = item.name;
  
  MPPlugin *plugin = [MPPluginHost.sharedHost pluginWithBundleIdentifier:item.bundleIdentifier];
  if(plugin) {
    if([plugin.humanVersionString isEqualToString:item.currentVersion]) {
      view.statusTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"INSTALLED_VERSION_%@_(UP_TO_DATE)", "Info displayed when an installed plugin is up to date"), plugin.humanVersionString];
    }
    else {
      view.statusTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"CURRENT_VERSION_%@_(INSTALLED_VERSION_%@)", "Info displayed when a plugin is loaded and "), item.currentVersion, plugin.humanVersionString];
    }
  }
  else {
    view.statusTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"CURRENT_VERSION_%@_(NOT_INSTALLED)", "Info displayed when an plugin is not installed"), plugin.humanVersionString];
  }
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
