//
//  MPPluginSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 09/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginSettingsController.h"
#import "MPPluginManager.h"
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

- (void)didLoadView {
  self.pluginTableView.delegate = self;
  self.pluginTableView.dataSource = self;
  
  [self.loadInsecurePlugsinCheckButton bind:NSValueBinding
                                   toObject:[NSUserDefaultsController sharedUserDefaultsController]
                                withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLoadUnsecurePlugins]
                                    options:nil];
  
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [MPPluginManager sharedManager].plugins.count;
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
  NSArray<MPPlugin __kindof *> *plugins = [MPPluginManager sharedManager].plugins;
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
