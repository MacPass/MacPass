//
//  MPPluginSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 09/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginSettingsController.h"

NSString *const _kMPPluginTableNameColumn = @"Name";
NSString *const _kMPPluginTableLoadedColumn = @"Loaded";

@interface MPPluginSettingsController () <NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *pluginTableView;

@end

@implementation MPPluginSettingsController

- (NSString *)nibName {
  return @"PluginSettings";
}

- (NSString *)identifier {
  return @"Plugins";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameApplicationIcon];
}

- (NSString *)label {
  return NSLocalizedString(@"PLUGIN_SETTINGS", "");
}

- (void)didLoadView {
  self.pluginTableView.tableColumns[0].identifier = _kMPPluginTableNameColumn;
  self.pluginTableView.tableColumns[1].identifier = _kMPPluginTableLoadedColumn;
  self.pluginTableView.tableColumns[0].title = NSLocalizedString(@"PLUGIN_TABLE_NAME_HEADER", "");
  self.pluginTableView.tableColumns[1].title = NSLocalizedString(@"PLUGIN_TABLE_LOAD_HEADER", "");

  //self.pluginTableView.delegate = self;
  self.pluginTableView.dataSource = self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return 2;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  if([tableColumn.identifier isEqualToString:_kMPPluginTableLoadedColumn]) {
    return @YES;
  }
  else if([tableColumn.identifier isEqualToString:_kMPPluginTableNameColumn]) {
    return @"DummyPlugin";
  }
  return nil;
}

@end
