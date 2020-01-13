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
#import "MPSettingsHelper.h"


typedef NS_ENUM(NSUInteger, MPPluginTableColumn) {
  MPPluginTableColumnName,
  MPPluginTableColumnCurrentVersion,
  MPPluginTableColumnStatus
};

@interface MPPluginRepositoryBrowserViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (copy) NSArray<MPPluginRepositoryItem *>* repositoryItems;
@property (strong) NSMutableSet<NSString *> *downloadedItems;
@property (strong) IBOutlet NSTableView *itemTable;
@property (strong) IBOutlet NSTextField *updatedAtTextField;

@end

@implementation MPPluginRepositoryBrowserViewController

- (NSNibName)nibName {
  return @"PluginRepositoryBrowserView";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.downloadedItems = [[NSMutableSet alloc] init];
  BOOL allowRemoteData = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyAllowRemoteFetchOfPluginRepository];
  if(allowRemoteData) {
    [self.updatedAtTextField bind:NSValueBinding toObject:MPPluginRepository.defaultRepository withKeyPath:NSStringFromSelector(@selector(updatedAt)) options:nil];
  }
  else {
    self.updatedAtTextField.stringValue = NSLocalizedString(@"REPOSITORY_UPDATED_AT_LOCAL", @"Updated at text when the local plugin defintino is used");
  }
  [self _refreshRepository];
}

- (void)refresh:(id)sender {
  [self _refreshRepository];
}

- (void)executePluginAction:(id)sender {
  NSInteger tableRow = [self.itemTable rowForView:sender];
  if(tableRow > -1 && tableRow < self.repositoryItems.count) {
    MPPluginRepositoryItem *item = self.repositoryItems[tableRow];
    if([self.downloadedItems containsObject:item.bundleIdentifier]) {
      NSURL *downloadsURL = [NSFileManager.defaultManager URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask].firstObject;
      [NSWorkspace.sharedWorkspace openURL:downloadsURL];
    }
    else {
      [self _downloadPluginForRow:tableRow];
    }
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
    statusView.actionButton.enabled = YES;
    
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
    
    // update action button
    
  }
  else {
    view.textField.stringValue = @"";
  }
  return view;
}

- (void)_refreshRepository {
  self.repositoryItems = MPPluginRepository.defaultRepository.availablePlugins;
  [self.itemTable reloadData];
}

- (NSButton *)_actionButtonForRow:(NSUInteger)row {
  MPPluginStatusTableCellView *view = [self.itemTable viewAtColumn:MPPluginTableColumnStatus row:row makeIfNecessary:NO];
  return view.actionButton;
}

- (void)_downloadPluginForRow:(NSInteger)row {
  NSButton *actionButton = [self _actionButtonForRow:row];
  actionButton.enabled = NO;
  actionButton.title = NSLocalizedString(@"PLUGIN_BROWSER_ACTION_DOWNLOAD_IN_PROGRESS", "Label for the button when a download is in progress!");
  
  MPPluginRepositoryItem *item = self.repositoryItems[row];
  NSURL *url = item.downloadURL;
  NSURLSessionDownloadTask *task = [NSURLSession.sharedSession downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSString *title = NSLocalizedString(@"PLUGIN_BROWSER_ACTION_RETRY_FAILED_DOWNLOAD", "Label for the button when a download did not succeed");
    if(httpResponse.statusCode == 200 && location != nil) {
      NSURL *downloadFolderURL = [NSFileManager.defaultManager URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask].firstObject;
      NSURL *fileURL = [downloadFolderURL URLByAppendingPathComponent:httpResponse.suggestedFilename];
      if([fileURL checkResourceIsReachableAndReturnError:&error]) {
        title = NSLocalizedString(@"PLUGIN_BROWSER_ACTION_SHOW_DOWNLOADED_FILE", "Label for the button to show a downloaded file");
        [self.downloadedItems addObject:item.bundleIdentifier];
      }
      else if([NSFileManager.defaultManager moveItemAtURL:location toURL:fileURL error:&error]) {
        title = NSLocalizedString(@"PLUGIN_BROWSER_ACTION_SHOW_DOWNLOADED_FILE", "Label for the button to show a downloaded file");
        [self.downloadedItems addObject:item.bundleIdentifier];
      }
      else {
        // more error handling
      }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      NSButton *actionButton = [self _actionButtonForRow:row];
      actionButton.title = title;
      actionButton.enabled = YES;
    });
  }];
  [task resume];
}
@end
