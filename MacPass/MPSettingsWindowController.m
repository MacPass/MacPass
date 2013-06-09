//
//  MPSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPSettingsWindowController.h"
#import "MPGeneralSettingsController.h"

@interface MPSettingsWindowController ()

@property (retain, nonatomic) NSToolbar *toolbar;
@property (retain, nonatomic) NSMutableDictionary *settingsController;
@property (retain, nonatomic) NSMutableDictionary *toolbarItems;

@end

@implementation MPSettingsWindowController

-(id)init {
  self = [super initWithWindowNibName:@"SettingsWindow"];
  if(self) {
    _toolbar = [[NSToolbar alloc] initWithIdentifier:@"SettingsToolBar"];
    [self.toolbar setAllowsUserCustomization:NO];
    [self.toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    _settingsController = [[NSMutableDictionary alloc] initWithCapacity:5];
    _toolbarItems = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    [self _setupDefaultSettingsTabs];
    
    [self.toolbar setDelegate:self];
    [[self window] setToolbar:self.toolbar];
  }
  return self;
}

- (void)dealloc {
  [_settingsController release];
  [_toolbar release];
  [_toolbarItems release];
  [super dealloc];
}

- (void)showSettings {
  if([self.settingsController count] > 0) {
    id<MPSettingsTab> tab = [self.settingsController allValues][0];
    NSString *identifier = [[tab class] identifier];
    [self showSettingsTabWithIdentifier:identifier];
  }
}

- (void)showSettingsTabWithIdentifier:(NSString *)identifier {
  if(nil == identifier) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Identifier cannot be nil" userInfo:nil];
  }
  id<MPSettingsTab> tab = self.settingsController[identifier];
  if(tab == nil){
    NSLog(@"Warning. Unknow settingscontroller for identifier: %@. Did you miss to add the controller?", identifier);
    return;
  }
  NSViewController *tabViewController = (NSViewController *)tab;
  [self.toolbar setSelectedItemIdentifier:identifier];
  NSRect newRect = [[self window] frameRectForContentRect:[tabViewController.view frame]];
  newRect.origin = [[self window] frame].origin;
  newRect.origin.y += [[self window] frame].size.height - newRect.size.height;
  [[self window] setFrame:newRect display:YES animate:YES];
  [[self window] setContentView:tabViewController.view];
  [[self window] makeKeyAndOrderFront:[self window]];
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
  NSString *identifier = [[tabController class] identifier];
  if(nil != self.settingsController[identifier]) {
    NSLog(@"Warning: Settingscontroller with identifer %@ already present!", identifier);
  }
  else {
    self.settingsController[identifier] = tabController;
  }
}

- (void)_setupDefaultSettingsTabs {
  MPGeneralSettingsController *generalSettingsController = [[MPGeneralSettingsController alloc] init];
  
  [self _addSettingsTab:generalSettingsController];
  
  [generalSettingsController release];
}

- (void)_showSettingsTab:(id)sender {
  if([sender respondsToSelector:@selector(identifier)]) {
    NSString *identfier = [sender identifier];
    [self showSettingsTabWithIdentifier:identfier];
  }
}

#pragma mark NSToolbarDelegate

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
  return [self.settingsController allKeys];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
  return [self.settingsController allKeys];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
  return [self.settingsController allKeys];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *item = self.toolbarItems[itemIdentifier];
  if(nil == item) {
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    /*
     Setup the item to use the controllers label if one is present
     and supports the appropriate @optional protocoll messages
     */
    id<MPSettingsTab> tab = self.settingsController[itemIdentifier];
    if([tab respondsToSelector:@selector(label)]) {
      [item setLabel:[tab label]];
    }
    else {
      [item setLabel:itemIdentifier];
    }
    if([tab respondsToSelector:@selector(image)]) {
      [item setImage:[tab image]];
    }
    else {
      [item setImage:[NSImage imageNamed:NSImageNameCaution ]];
    }
    
    [item setAction:@selector(_showSettingsTab:)];
    self.toolbarItems[itemIdentifier] = item;
  }
  return item;
}

@end
