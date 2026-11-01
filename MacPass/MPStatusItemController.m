//
//  MPStatusItemController.m
//  MacPass
//
//  Created for menu bar / status item support.
//  Copyright (c) HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPStatusItemController.h"

#import "MPAppDelegate.h"
#import "MPDocument.h"
#import "MPSettingsHelper.h"

#import "NSApplication+MPAdditions.h"

static void *MPStatusItemObservingContext = &MPStatusItemObservingContext;

@interface MPStatusItemController ()

@property (strong) NSStatusItem *statusItem;

@end

@implementation MPStatusItemController

- (instancetype)init {
  self = [super init];
  if(self) {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults addObserver:self forKeyPath:kMPSettingsKeyShowStatusItem options:NSKeyValueObservingOptionInitial context:MPStatusItemObservingContext];
    [defaults addObserver:self forKeyPath:kMPSettingsKeyHideDockIcon options:NSKeyValueObservingOptionInitial context:MPStatusItemObservingContext];
  }
  return self;
}

- (void)dealloc {
  NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
  [defaults removeObserver:self forKeyPath:kMPSettingsKeyShowStatusItem context:MPStatusItemObservingContext];
  [defaults removeObserver:self forKeyPath:kMPSettingsKeyHideDockIcon context:MPStatusItemObservingContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if(context != MPStatusItemObservingContext) {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
  }
  [self _updateStatusItemVisibility];
  [self _updateDockIconVisibility];
}

#pragma mark - Visibility

- (BOOL)_shouldShowStatusItem {
  NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
  /* Always keep a status item while the Dock icon is hidden so the app remains reachable */
  if([defaults boolForKey:kMPSettingsKeyHideDockIcon]) {
    return YES;
  }
  return [defaults boolForKey:kMPSettingsKeyShowStatusItem];
}

- (void)_updateStatusItemVisibility {
  BOOL show = [self _shouldShowStatusItem];
  if(show && !self.statusItem) {
    [self _createStatusItem];
  }
  else if(!show && self.statusItem) {
    [NSStatusBar.systemStatusBar removeStatusItem:self.statusItem];
    self.statusItem = nil;
  }
}

- (void)_updateDockIconVisibility {
  BOOL hideDockIcon = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyHideDockIcon];
  NSApplicationActivationPolicy policy = hideDockIcon ? NSApplicationActivationPolicyAccessory : NSApplicationActivationPolicyRegular;
  if(NSApp.activationPolicy == policy) {
    return;
  }
  [NSApp setActivationPolicy:policy];
  /* Changing activation policy deactivates the app; reactivate so open windows stay usable */
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp activateIgnoringOtherApps:YES];
  });
}

- (void)_createStatusItem {
  NSStatusItem *item = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
  NSImage *statusImage = nil;
  if(@available(macOS 11.0, *)) {
    statusImage = [NSImage imageWithSystemSymbolName:@"lock.fill" accessibilityDescription:NSApp.applicationName];
  }
  if(!statusImage) {
    statusImage = [NSApp.applicationIconImage copy];
    statusImage.size = NSMakeSize(18.0, 18.0);
  }
  statusImage.template = YES;
  item.button.image = statusImage;
  item.button.toolTip = NSApp.applicationName;
  item.menu = [self _buildStatusMenu];
  self.statusItem = item;
}

- (NSMenu *)_buildStatusMenu {
  NSMenu *menu = [[NSMenu alloc] init];

  NSMenuItem *showItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"STATUS_BAR_MENU_SHOW_MACPASS", @"Status bar menu item to show MacPass")
                                                    action:@selector(showApplication:)
                                             keyEquivalent:@""];
  showItem.target = self;
  [menu addItem:showItem];

  NSMenuItem *unlockItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"STATUS_BAR_MENU_UNLOCK_DATABASES", @"Status bar menu item to bring locked databases forward for unlock")
                                                      action:@selector(unlockDatabases:)
                                               keyEquivalent:@""];
  unlockItem.target = self;
  [menu addItem:unlockItem];

  NSMenuItem *lockItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"STATUS_BAR_MENU_LOCK_ALL_DATABASES", @"Status bar menu item to lock all open databases")
                                                    action:@selector(lockAllDocuments:)
                                             keyEquivalent:@""];
  lockItem.target = self;
  [menu addItem:lockItem];

  [menu addItem:NSMenuItem.separatorItem];

  NSMenuItem *preferencesItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"STATUS_BAR_MENU_PREFERENCES", @"Status bar menu item to show the preferences")
                                                           action:@selector(showPreferences:)
                                                    keyEquivalent:@""];
  preferencesItem.target = self;
  [menu addItem:preferencesItem];

  [menu addItem:NSMenuItem.separatorItem];

  NSString *quitTitle = [NSString stringWithFormat:NSLocalizedString(@"STATUS_BAR_MENU_QUIT_MACPASS_%@", @"Status bar menu item to quit MacPass. %@ is the application name."), NSApp.applicationName];
  NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                    action:@selector(terminate:)
                                             keyEquivalent:@""];
  quitItem.target = NSApp;
  [menu addItem:quitItem];

  return menu;
}

#pragma mark - Actions

- (void)showApplication:(id)sender {
  [NSApp activateIgnoringOtherApps:YES];
  BOOL hasVisibleWindows = NO;
  for(NSWindow *window in NSApp.windows) {
    if(window.isVisible && window.canBecomeMainWindow) {
      hasVisibleWindows = YES;
      [window makeKeyAndOrderFront:sender];
    }
  }
  MPAppDelegate *delegate = NSApp.mp_delegate;
  [delegate applicationShouldHandleReopen:NSApp hasVisibleWindows:hasVisibleWindows];
}

- (void)unlockDatabases:(id)sender {
  [NSApp activateIgnoringOtherApps:YES];
  BOOL broughtAny = NO;
  for(MPDocument *document in NSDocumentController.sharedDocumentController.documents) {
    if(!document.encrypted) {
      continue;
    }
    for(NSWindowController *windowController in document.windowControllers) {
      [windowController.window makeKeyAndOrderFront:sender];
      broughtAny = YES;
    }
  }
  if(!broughtAny) {
    [self showApplication:sender];
  }
}

- (void)lockAllDocuments:(id)sender {
  [NSApp.mp_delegate lockAllDocuments];
}

- (void)showPreferences:(id)sender {
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp.mp_delegate showPreferences:sender];
}

#pragma mark - NSMenuItemValidation / NSMenuDelegate

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if(menuItem.action == @selector(lockAllDocuments:)) {
    for(MPDocument *document in NSDocumentController.sharedDocumentController.documents) {
      if(!document.encrypted) {
        return YES;
      }
    }
    return NO;
  }
  if(menuItem.action == @selector(unlockDatabases:)) {
    for(MPDocument *document in NSDocumentController.sharedDocumentController.documents) {
      if(document.encrypted) {
        return YES;
      }
    }
    return NO;
  }
  return YES;
}

@end
