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
#import "MPPluginVersionComparator.h"


typedef NS_ENUM(NSUInteger, MPPluginTableColumn) {
  MPPluginTableColumnName,
  MPPluginTableColumnCurrentVersion,
  MPPluginTableColumnStatus
};

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
  return self.repositoryItems.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  MPPluginRepositoryItem *item = self.repositoryItems[row];
  
  NSUInteger column = [tableView.tableColumns indexOfObjectIdenticalTo:tableColumn];

  if(column == MPPluginTableColumnName) {
    view.textField.stringValue = item.name;
  }
  else if(column == MPPluginTableColumnCurrentVersion) {
    view.textField.stringValue = item.currentVersion;
  }
  else if(column == MPPluginTableColumnStatus) {
    MPPlugin *plugin = [MPPluginHost.sharedHost pluginWithBundleIdentifier:item.bundleIdentifier];
    if(plugin) {
      switch([MPPluginVersionComparator compareVersion:plugin.shortVersionString toVersion:item.currentVersion]) {
        case NSOrderedSame:
          view.textField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_BROWSER_LATEST_VERSION_INSTALLED", "Status for an up-to-date plugin in the plugin browser")];
          break;
        case NSOrderedAscending:
          view.textField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_BROWSER_NEWER_VERSION_%@_AVAILABLE", "Status for an outdated plugin version in the plugin browser"), item.currentVersion];
          break;
        case NSOrderedDescending:
          view.textField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_BROWSER_UNKNOWN_PLUGIN_VERSION_INSTALLED_%@", "Status for an unkonw plugin version in the plugin browser"), plugin.shortVersionString];
          break;
      }
    }
    else {
      view.textField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_BROWSER_PLUGIN_NOT_INSTALLED", "Status for an uninstalled plugin in the plugin browser")];
    }
  }
  else {
    view.textField.stringValue = @"-";
  }
  return view;
  
}

- (void)_refreshRepository {
  self.repositoryItems = MPPluginRepository.defaultRepository.availablePlugins;
  [self.itemTable reloadData];
}


@end
