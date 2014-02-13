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

#pragma mark LifeCycle
- (id)init {
  self = [self initWithNibName:@"WorkflowSettings" bundle:nil];
  return self;
}

- (void)didLoadView {
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

- (void)willSelectTab {
  [self _updateBrowserSelection];
}

#pragma mark Actions
- (void)selectBrowser:(id)sender {
  NSString *browserBundleId = [sender representedObject];
  NSLog(@"New default Browser: %@", browserBundleId);
  [[NSUserDefaults standardUserDefaults] setObject:browserBundleId forKey:kMPSettingsKeyBrowserBundleId];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showCustomBrowserSelection:(id)sender {
  NSAssert(NO,@"Not implemented!");
}

#pragma mark Helper
- (void)_updateBrowserSelection {
  /* Use a delegate ? */
  NSMenu *browserMenu = [[NSMenu alloc] init];
  [self.browserPopup setMenu:browserMenu];

  [browserMenu addItemWithTitle:NSLocalizedString(@"DEFAULT_BROWSER", "Default Browser") action:NULL keyEquivalent:@""];
  [browserMenu addItem:[NSMenuItem separatorItem]];
  
  for(NSString *bundleIdentifier in [self _bundleIdentifierForHTTPS]) {
    NSString *bundlePath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier];
    NSString *browserName = [[NSFileManager defaultManager] displayNameAtPath:bundlePath];
    NSMenuItem *browserItem = [[NSMenuItem alloc] initWithTitle:browserName action:@selector(selectBrowser:) keyEquivalent:@""];
    [browserItem setRepresentedObject:bundleIdentifier];
    [browserItem setTarget:self];
    [browserMenu addItem:browserItem];
  }
  
  if([[browserMenu itemArray] count] > 2) {
    [browserMenu addItem:[NSMenuItem separatorItem]];
  }
  NSMenuItem *selectOtherBrowserItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OTHER_BROWSER", "Selecte Browser")
                                                                  action:@selector(showCustomBrowserSelection:)
                                                           keyEquivalent:@""];
  [selectOtherBrowserItem setTarget:self];
  [browserMenu addItem:selectOtherBrowserItem];
}

- (NSArray *)_bundleIdentifierForHTTPS {
  NSArray *browserBundles = CFBridgingRelease(LSCopyAllHandlersForURLScheme(CFSTR("https")));
  return browserBundles;
}

@end
