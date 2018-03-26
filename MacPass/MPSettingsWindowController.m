//
//  MPSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
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

#import "MPSettingsWindowController.h"
#import "MPGeneralSettingsController.h"
#import "MPIntegrationSettingsController.h"
#import "MPWorkflowSettingsController.h"
#import "MPUpdateSettingsController.h"
#import "MPPluginSettingsController.h"

@interface MPSettingsWindowController () {
  NSString *lastIdentifier;
}

@property (strong, nonatomic) NSMutableDictionary *settingsController;
@property (strong, nonatomic) NSMutableDictionary *toolbarItems;
@property (strong) NSArray *defaultToolbarItems;

@end

@implementation MPSettingsWindowController

- (NSString *)windowNibName {
  return @"SettingsWindow";
}

-(id)init {
  self = [super initWithWindow:nil];
  if(self) {
    NSToolbar *tb = [[NSToolbar alloc] initWithIdentifier:@"SettingsToolBar"];
    tb.allowsUserCustomization = NO;
    tb.displayMode = NSToolbarDisplayModeIconAndLabel;
    _settingsController = [[NSMutableDictionary alloc] initWithCapacity:5];
    _toolbarItems = [[NSMutableDictionary alloc] initWithCapacity:5];
    lastIdentifier = nil;
    
    [self _setupDefaultSettingsTabs];
    
    tb.delegate = self;
    self.window.toolbar = tb;
  }
  return self;
}


- (void)showSettings {
  if(self.defaultToolbarItems.count > 0) {
    [self showSettingsTabWithIdentifier:self.defaultToolbarItems[0]];
  }
}

- (void)showSettingsTabWithIdentifier:(NSString *)identifier {
  if(nil == identifier) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Identifier cannot be nil" userInfo:nil];
  }
  id<MPSettingsTab> tab = self.settingsController[identifier];
  if(tab == nil){
    NSLog(@"Warning. Unknown settingscontroller for identifier: %@. Did you miss to add the controller?", identifier);
    return;
  }
  self.window.toolbar.selectedItemIdentifier = identifier;
  if([tab respondsToSelector:@selector(label)]) {
    self.window.title = [tab label];
  }
  else {
    self.window.title = [tab identifier];
  }
  /* Access the view before calling the willShoTab to make sure the view is fully loaded */
  NSView *tabView = [(NSViewController *)tab view];
  if([tab respondsToSelector:@selector(willShowTab)]) {
    [tab willShowTab];
  }
  NSView *contentView = self.window.contentView;
  if( contentView.subviews.count == 1) {
    [contentView.subviews.firstObject removeFromSuperview];
  }
  [contentView addSubview:tabView];
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tabView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(tabView)]];
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tabView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(tabView)]];
  
  [contentView layout];
  [contentView layoutSubtreeIfNeeded];
  if([tab respondsToSelector:@selector(didShowTab)]) {
    [tab didShowTab];
  }
  [self.window makeKeyAndOrderFront:nil];
}

- (void)_addSettingsTab:(id<MPSettingsTab>)tabController {
  if(NO == [tabController conformsToProtocol:@protocol(MPSettingsTab)]) {
    NSException *protocollException = [NSException exceptionWithName:NSInvalidArgumentException
                                                              reason:@"Controller must conform to MPSettingsTabProtrocoll"
                                                            userInfo:nil];
    @throw protocollException;
  }
  if(NO == [tabController isKindOfClass:[NSViewController class]]) {
    NSException *controllerException = [NSException exceptionWithName:NSInvalidArgumentException
                                                               reason:@"Controller is no NSViewController"
                                                             userInfo:nil];
    @throw controllerException;
  }
  NSString *identifier = tabController.identifier;
  if(nil != self.settingsController[identifier]) {
    NSLog(@"Warning: Settingscontroller with identifier %@ already present!", identifier);
  }
  else {
    self.settingsController[identifier] = tabController;
  }
}

- (void)_setupDefaultSettingsTabs {
  NSArray *controllers = @[ [[MPGeneralSettingsController alloc] init],
                         [[MPIntegrationSettingsController alloc] init],
                         [[MPWorkflowSettingsController alloc] init],
                         [[MPUpdateSettingsController alloc] init],
                         [[MPPluginSettingsController alloc] init] ];
  NSMutableArray *identifier = [[NSMutableArray alloc] initWithCapacity:controllers.count];
  for(id<MPSettingsTab> controller in controllers) {
    [self _addSettingsTab:controller];
    [identifier addObject:controller.identifier];
  }
  self.defaultToolbarItems = [identifier copy];
}

- (void)_showSettingsTab:(id)sender {
  if([sender respondsToSelector:@selector(itemIdentifier)]) {
    NSString *identfier = [sender itemIdentifier];
    [self showSettingsTabWithIdentifier:identfier];
  }
}

#pragma mark NSToolbarDelegate

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
  return self.settingsController.allKeys;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
  return self.defaultToolbarItems;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
  return self.settingsController.allKeys;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *item = self.toolbarItems[itemIdentifier];
  if(nil == item) {
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    /*
     Setup the item to use the controllers label if one is present
     and supports the appropriate @optional protocol messages
     */
    id<MPSettingsTab> tab = self.settingsController[itemIdentifier];
    if([tab respondsToSelector:@selector(label)]) {
      item.label = [tab label];
    }
    else {
      item.label = itemIdentifier;
    }
    if([tab respondsToSelector:@selector(image)]) {
      item.image = [tab image];
    }
    else {
      item.image = [NSImage imageNamed:NSImageNameCaution];
    }
    
    item.action = @selector(_showSettingsTab:);
    self.toolbarItems[itemIdentifier] = item;
  }
  return item;
}

@end
