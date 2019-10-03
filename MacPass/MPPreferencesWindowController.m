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

#import "MPPreferencesWindowController.h"

#import "MPPreferencesTab.h"

#import "MPGeneralPreferencesController.h"
#import "MPIntegrationPreferencesController.h"
#import "MPWorkflowPreferencesController.h"
#import "MPUpdatePreferencesController.h"
#import "MPPluginPreferencesController.h"

@interface MPPreferencesWindowController () {
  NSString *lastIdentifier;
}

@property (strong, nonatomic) NSMutableDictionary *preferencesController;
@property (strong, nonatomic) NSMutableDictionary *toolbarItems;
@property (strong) NSArray *defaultToolbarItems;

@end

@implementation MPPreferencesWindowController

- (NSString *)windowNibName {
  return @"PreferencesWindow";
}

-(id)init {
  self = [super initWithWindow:nil];
  if(self) {
    NSToolbar *tb = [[NSToolbar alloc] initWithIdentifier:@"PreferencesToolBar"];
    tb.allowsUserCustomization = NO;
    tb.displayMode = NSToolbarDisplayModeIconAndLabel;
    _preferencesController = [[NSMutableDictionary alloc] initWithCapacity:5];
    _toolbarItems = [[NSMutableDictionary alloc] initWithCapacity:5];
    lastIdentifier = nil;
    
    [self _setupDefaultPreferencesTabs];
    
    tb.delegate = self;
    self.window.toolbar = tb;
  }
  return self;
}


- (void)showPreferences {
  if(self.defaultToolbarItems.count > 0) {
    [self _showPreferencesTabWithIdentifier:self.defaultToolbarItems[0]];
  }
}

- (void)_showPreferencesTabWithIdentifier:(NSString *)identifier {
  if(nil == identifier) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Identifier cannot be nil" userInfo:nil];
  }
  id<MPPreferencesTab> tab = self.preferencesController[identifier];
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

- (void)showPreferencesTab:(MPPreferencesTab)tab {
  Class tabClass;
  switch(tab) {
    case MPPreferencesTabPlugins:
      tabClass = MPPluginPreferencesController.class;
      break;
    case MPPreferencesTabUpdate:
      tabClass = MPUpdatePreferencesController.class;
      break;
    case MPPreferencesTabWorkflow:
      tabClass = MPWorkflowPreferencesController.class;
      break;
    case MPPreferencesTabGeneral:
    default:
      tabClass = MPGeneralPreferencesController.class;
      break;
  }
  NSString *identifier;
  for(id<MPPreferencesTab> tab in self.preferencesController.allValues) {
    if([tab isKindOfClass:tabClass]) {
      identifier = tab.identifier;
      break;
    }
  }
  [self _showPreferencesTabWithIdentifier:identifier];
}

- (void)_addSettingsTab:(id<MPPreferencesTab>)tabController {
  if(NO == [tabController conformsToProtocol:@protocol(MPPreferencesTab)]) {
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
  if(nil != self.preferencesController[identifier]) {
    NSLog(@"Warning: Settingscontroller with identifier %@ already present!", identifier);
  }
  else {
    self.preferencesController[identifier] = tabController;
  }
}

- (void)_setupDefaultPreferencesTabs {
  NSArray *controllers = @[ [[MPGeneralPreferencesController alloc] init],
                            [[MPIntegrationPreferencesController alloc] init],
                            [[MPWorkflowPreferencesController alloc] init],
                            [[MPUpdatePreferencesController alloc] init],
                            [[MPPluginPreferencesController alloc] init] ];
  NSMutableArray *identifier = [[NSMutableArray alloc] initWithCapacity:controllers.count];
  for(id<MPPreferencesTab> controller in controllers) {
    [self _addSettingsTab:controller];
    [identifier addObject:controller.identifier];
  }
  self.defaultToolbarItems = [identifier copy];
}

- (void)_showSettingsTab:(id)sender {
  if([sender respondsToSelector:@selector(itemIdentifier)]) {
    NSString *identfier = [sender itemIdentifier];
    [self _showPreferencesTabWithIdentifier:identfier];
  }
}

#pragma mark NSToolbarDelegate

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
  return self.preferencesController.allKeys;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
  return self.defaultToolbarItems;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
  return self.preferencesController.allKeys;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *item = self.toolbarItems[itemIdentifier];
  if(nil == item) {
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    /*
     Setup the item to use the controllers label if one is present
     and supports the appropriate @optional protocol messages
     */
    id<MPPreferencesTab> tab = self.preferencesController[itemIdentifier];
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
