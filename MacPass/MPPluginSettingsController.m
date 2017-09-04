//
//  MPPluginSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 09/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPPluginSettingsController.h"
#import "MPPluginHost.h"
#import "MPPlugin.h"

#import "MPSettingsHelper.h"

@interface MPPluginSettingsController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *pluginTableView;
@property (weak) IBOutlet NSView *settingsView;
@property (weak) IBOutlet NSButton *loadInsecurePlugsinCheckButton;

@end

@implementation MPPluginSettingsController

- (NSString *)nibName {
  return @"PluginSettings";
}

- (NSString *)identifier {
  return @"Plugins";
}

- (NSImage *)image {
  return [[NSWorkspace sharedWorkspace] iconForFileType:@"bundle"];
}

- (NSString *)label {
  return NSLocalizedString(@"PLUGIN_SETTINGS", "");
}

- (void)viewDidLoad {
  self.pluginTableView.delegate = self;
  self.pluginTableView.dataSource = self;
  
  [self.loadInsecurePlugsinCheckButton bind:NSValueBinding
                                   toObject:[NSUserDefaultsController sharedUserDefaultsController]
                                withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLoadUnsecurePlugins]
                                    options:nil];
  
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [MPPluginHost sharedHost].plugins.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  MPPlugin *plugin = [self pluginForRow:row];
  NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
  view.textField.stringValue = plugin.name;
  return view;
}

- (void)showSettingsForPlugin:(MPPlugin *)plugin {
  /* move old one regardless */
  [self.settingsView.subviews.firstObject removeFromSuperview];
  if([plugin conformsToProtocol:@protocol(MPPluginSettings)]) {
    NSAssert([plugin respondsToSelector:@selector(settingsViewController)], @"Required getter for settings on plugins");
    NSViewController *viewController = ((id<MPPluginSettings>)plugin).settingsViewController;
    [self.settingsView addSubview:viewController.view];
    NSDictionary *dict = @{ @"view" : viewController.view,
                            @"table" : self.pluginTableView.enclosingScrollView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:dict]];
  }
}

- (MPPlugin *)pluginForRow:(NSInteger)row {
  NSArray<MPPlugin __kindof *> *plugins = [MPPluginHost sharedHost].plugins;
  if(0 > row || row >= plugins.count) {
    return nil;
  }
  return plugins[row];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *table = notification.object;
  [self showSettingsForPlugin:[self pluginForRow:table.selectedRow]];
}

@end
