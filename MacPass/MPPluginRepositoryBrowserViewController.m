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
#import "MPPluginStatusTableCellView.h"


typedef NS_ENUM(NSUInteger, MPPluginTableColumn) {
  MPPluginTableColumnName,
  MPPluginTableColumnCurrentVersion,
  MPPluginTableColumnStatus
};

@interface MPPluginRepositoryBrowserViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (copy) NSArray<MPPluginRepositoryItem *>* repositoryItems;
@property (strong) IBOutlet NSTableView *itemTable;
@property (strong) IBOutlet NSTextField *updatedAtTextField;

@end

@implementation MPPluginRepositoryBrowserViewController

- (NSNibName)nibName {
  return @"PluginRepositoryBrowserView";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.updatedAtTextField bind:NSValueBinding toObject:MPPluginRepository.defaultRepository withKeyPath:NSStringFromSelector(@selector(updatedAt)) options:nil];
  [self _refreshRepository];
}

- (void)refresh:(id)sender {
  [self _refreshRepository];
}

- (void)executePluginAction:(id)sender {
  NSInteger tableRow = [self.itemTable rowForView:sender];
  if(tableRow > -1 && tableRow < self.repositoryItems.count) {
    MPPluginRepositoryItem *actionItem = self.repositoryItems[tableRow];
    [self _downloadPluginForItem:actionItem];
  }
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
    MPPluginStatusTableCellView *statusView = (MPPluginStatusTableCellView *)view;
    statusView.actionButton.title = NSLocalizedString(@"PLUGIN_BROWSER_DOWNLOAD_PLUGIN_BUTTON", "Button to download the Plugin");
    
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

- (void)_downloadPluginForItem:(MPPluginRepositoryItem *)item {
  NSURL *url = item.downloadURL;
  NSURLSessionDownloadTask *task = [NSURLSession.sharedSession downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if(httpResponse.statusCode == 200) {
      if(location) {
        NSError *error;
        NSURL *downloadFolderURL = [NSFileManager.defaultManager URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask].firstObject;
        NSURL *fileURL = [downloadFolderURL URLByAppendingPathComponent:httpResponse.suggestedFilename];
        [NSFileManager.defaultManager moveItemAtURL:location toURL:fileURL error:&error];
      }
    }
  }];
  [task resume];
}
@end
