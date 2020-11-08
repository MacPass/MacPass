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
#import "MPTabViewController.h"

@interface MPPreferencesWindowController ()

@property (strong) MPTabViewController *tabViewController;

@end

@implementation MPPreferencesWindowController

- (NSString *)windowNibName {
  return @"PreferencesWindow";
}

-(id)init {
  self = [super initWithWindow:nil];
  if(self) {
    _tabViewController = [[MPTabViewController alloc] init];
    _tabViewController.tabStyle = NSTabViewControllerTabStyleToolbar;
    _tabViewController.transitionOptions = NSViewControllerTransitionNone | NSViewControllerTransitionAllowUserInteraction;
    
    self.contentViewController  = self.tabViewController;
    
    _tabViewController.willSelectTabHandler = ^void(NSTabViewItem *item) {
      if([item.viewController respondsToSelector:@selector(willShowTab)]) {
        [(id<MPPreferencesTab>)item.viewController willShowTab];
      }
    };
    
    _tabViewController.didSelectTabHandler = ^void(NSTabViewItem *item) {
      if([item.viewController respondsToSelector:@selector(didShowTab)]) {
        [(id<MPPreferencesTab>)item.viewController didShowTab];
      }
    };
    
    [self _setupDefaultPreferencesTabs];
  }
  return self;
}


- (void)showPreferences {
  [self showPreferencesTab:MPPreferencesTabGeneral];
}

- (void)_showPreferencesTabWithIdentifier:(NSString *)identifier {
  if(nil == identifier) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Identifier cannot be nil" userInfo:nil];
  }
  
  NSInteger index = [self.tabViewController.tabView indexOfTabViewItemWithIdentifier:identifier];
  /* fall back to first index if requested identifier is not know */
  if(index == NSNotFound) {
    index = 0;
  }
  
  NSTabViewItem *item = self.tabViewController.tabViewItems[index];
  
  if(item.label.length > 0) {
    self.window.title = item.label;
  }
  else {
    self.window.title = item.identifier;
  }
  if([item.viewController respondsToSelector:@selector(willShowTab)]) {
    [(id<MPPreferencesTab>)item.viewController willShowTab];
  }
  self.tabViewController.selectedTabViewItemIndex = index;
  
  if([item.viewController respondsToSelector:@selector(didShowTab)]) {
    [(id<MPPreferencesTab>)item.viewController didShowTab];
  }
  [self.window makeKeyAndOrderFront:nil];
}

- (void)showPreferencesTab:(MPPreferencesTab)tab {
  Class tabClass;
  switch(tab) {
    case MPPreferencesTabPlugins:
      tabClass = MPPluginPreferencesController.class;
      break;
    case MPPreferencesTabIntegration:
      tabClass = MPIntegrationPreferencesController.class;
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
  for(NSTabViewItem *tabViewItem in self.tabViewController.tabViewItems) {
    if([tabViewItem.viewController isKindOfClass:tabClass]) {
      identifier = tabViewItem.identifier;
      break;
    }
  }
  [self _showPreferencesTabWithIdentifier:identifier];
}

- (void)_setupDefaultPreferencesTabs {
  NSArray<NSViewController<MPPreferencesTab>*> *controllers = @[ [[MPGeneralPreferencesController alloc] init],
                                                                 [[MPIntegrationPreferencesController alloc] init],
                                                                 [[MPWorkflowPreferencesController alloc] init],
                                                                 [[MPUpdatePreferencesController alloc] init],
                                                                 [[MPPluginPreferencesController alloc] init] ];
  for(NSViewController<MPPreferencesTab> *controller in controllers) {
    NSString *identifier = controller.identifier;
    if([self.tabViewController tabViewItemForViewController:controller]) {
      NSLog(@"Skipping adding tabViewController %@ since it's already been added before", controller);
      continue;
    }
    if(NSNotFound != [self.tabViewController.tabView indexOfTabViewItemWithIdentifier:identifier]) {
      NSLog(@"Warning: Duplicate identifiers %@ used for different tabs. Skipping adding %@ since the identifier is not unique", identifier, controller);
    }
    NSTabViewItem *item = [NSTabViewItem tabViewItemWithViewController:controller];
    item.identifier = controller.identifier;
    if([controller respondsToSelector:@selector(label)]) {
      item.label = controller.label;
    }
    if([controller respondsToSelector:@selector(image)]) {
      item.image = controller.image;
    }
    [self.tabViewController addTabViewItem:item];
  }
}


@end
