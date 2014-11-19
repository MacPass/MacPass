//
//  MPWorkflowSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 30.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPWorkflowSettingsController.h"

#import "MPSettingsHelper.h"

@interface MPWorkflowSettingsController ()

@end

@implementation MPWorkflowSettingsController

- (NSString *)nibName {
  return @"WorkflowSettings";
}

- (void)didLoadView {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  
  [self.doubleClickURLPopup bind:NSSelectedIndexBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyDoubleClickURLAction] options:nil];
  [self.doubleClickTitlePopup bind:NSSelectedIndexBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyDoubleClickTitleAction] options:nil];
  
  [self _updateBrowserSelection];
}

#pragma mark MPSettingsTab Protocol
- (NSString *)identifier {
  return @"WorkflowSettings";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)label {
  return NSLocalizedString(@"WORKFLOW_SETTINGS", "");
}

- (void)willShowTab {
  [self _updateBrowserSelection];
}

#pragma mark Actions
- (void)_selectBrowser:(id)sender {
  NSString *browserBundleId = [sender representedObject];
  if(nil == browserBundleId) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMPSettingsKeyBrowserBundleId];
  }
  else {
    [[NSUserDefaults standardUserDefaults] setObject:browserBundleId forKey:kMPSettingsKeyBrowserBundleId];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self _updateBrowserSelection];
}

- (void)_showCustomBrowserSelection:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  NSURL *applicationURL = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask][0];
  [openPanel setDirectoryURL:applicationURL];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setAllowedFileTypes:@[@"app"]];
  
  [openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      // TODO: Autorelease pool?
      NSMenuItem *customBrowser = [[NSMenuItem alloc] init];
      [customBrowser setRepresentedObject:[[NSBundle bundleWithPath:[[openPanel URL] path]] bundleIdentifier]];
      [self _selectBrowser:customBrowser];
    }
    else {
      /* Reset the selection if the user cancels */
      [self _updateBrowserSelection];
    }
  }];
}

#pragma mark Helper
- (void)_updateBrowserSelection {
  /* Use a delegate ? */
  NSMenu *browserMenu = [[NSMenu alloc] init];
  [self.browserPopup setMenu:browserMenu];
  
  NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DEFAULT_BROWSER", "Default Browser") action:@selector(_selectBrowser:) keyEquivalent:@""];
  [defaultItem setRepresentedObject:nil];
  [defaultItem setTarget:self];
  [browserMenu addItem:defaultItem];
  
  NSString *currentDefaultBrowser = [[NSUserDefaults standardUserDefaults] objectForKey:kMPSettingsKeyBrowserBundleId];
  NSMenuItem *selectedItem = defaultItem;
  
  [browserMenu addItem:[NSMenuItem separatorItem]];
  
  for(NSString *bundleIdentifier in [self _bundleIdentifierForHTTPS]) {
    NSString *bundlePath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier];
    NSString *browserName = [[NSFileManager defaultManager] displayNameAtPath:bundlePath];
    if(nil == bundlePath || nil == browserName) {
      continue; // Skip missing Applications
    }
    NSMenuItem *browserItem = [[NSMenuItem alloc] initWithTitle:browserName action:@selector(_selectBrowser:) keyEquivalent:@""];
    [browserItem setRepresentedObject:bundleIdentifier];
    [browserItem setTarget:self];
    [browserMenu addItem:browserItem];
    
    if ([bundleIdentifier isEqualToString:currentDefaultBrowser]) {
      selectedItem = browserItem;
    }
  }
  
  if([[browserMenu itemArray] count] > 2) {
    [browserMenu addItem:[NSMenuItem separatorItem]];
  }
  
  if (currentDefaultBrowser != nil && selectedItem == defaultItem) {
    NSString *bundlePath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:currentDefaultBrowser];
    if (bundlePath != nil) {
      NSString *browserName = [[NSFileManager defaultManager] displayNameAtPath:bundlePath];
      NSMenuItem *browserItem = [[NSMenuItem alloc] initWithTitle:browserName action:@selector(_selectBrowser:) keyEquivalent:@""];
      [browserItem setRepresentedObject:currentDefaultBrowser];
      [browserItem setTarget:self];
      [browserMenu addItem:browserItem];
      
      selectedItem = browserItem;
    }
  }
  
  NSMenuItem *selectOtherBrowserItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OTHER_BROWSER", "Select Browser")
                                                                  action:@selector(_showCustomBrowserSelection:)
                                                           keyEquivalent:@""];
  [selectOtherBrowserItem setTarget:self];
  
  [browserMenu addItem:selectOtherBrowserItem];
  [self.browserPopup selectItem:selectedItem];
}

- (NSArray *)_bundleIdentifierForHTTPS {
  NSArray *browserBundles = CFBridgingRelease(LSCopyAllHandlersForURLScheme(CFSTR("https")));
  return browserBundles;
}

@end
