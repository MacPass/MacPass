//
//  MPWorkflowSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 30.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import "MPWorkflowPreferencesController.h"

#import "MPSettingsHelper.h"

#import "DDHotKeyCenter.h"
#import "DDHotKey+MacPassAdditions.h"
#import "DDHotKeyTextField.h"


@interface MPWorkflowPreferencesController ()



@property (strong) IBOutlet NSPopUpButton *browserPopup;
@property (strong) IBOutlet NSPopUpButton *doubleClickURLPopup;
@property (strong) IBOutlet NSPopUpButton *doubleClickTitlePopup;
@property (strong) IBOutlet NSButton *updatePasswordOnTemplateEntriesCheckButton;
@property (strong) IBOutlet NSButton *generatePasswordOnEntriesCheckButton;
@property (strong) IBOutlet NSButton *hideAfterCopyToClipboardCheckButton;
@property (strong) IBOutlet NSButton *focusSearchAfterUnlockCheckButton;

//@property (strong) IBOutlet NSButton *privateBrowsingCheckButton;
@property (strong) IBOutlet NSButton *showOrHideMacPassCheckButton;
@property (nonatomic, strong) DDHotKey *hotKey;
@property (strong) IBOutlet NSButtonCell *focusSearchAfterHotkey;


- (IBAction)_showCustomBrowserSelection:(id)sender;

@end

@implementation MPWorkflowPreferencesController

- (NSString *)nibName {
  return @"WorkflowPreferences";
}

- (void)viewDidLoad {
  NSUserDefaultsController *defaultsController = NSUserDefaultsController.sharedUserDefaultsController;
  
  [self.doubleClickURLPopup bind:NSSelectedIndexBinding
                        toObject:defaultsController
                     withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyDoubleClickURLAction]
                         options:nil];
  [self.doubleClickTitlePopup bind:NSSelectedIndexBinding
                          toObject:defaultsController
                       withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyDoubleClickTitleAction]
                           options:nil];
  [self.updatePasswordOnTemplateEntriesCheckButton bind:NSValueBinding
                                               toObject:defaultsController
                                            withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyUpdatePasswordOnTemplateEntries]
                                                options:nil];
  [self.generatePasswordOnEntriesCheckButton bind:NSValueBinding
                                         toObject:defaultsController
                                      withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyGeneratePasswordForNewEntires]
                                          options:nil];
  [self.hideAfterCopyToClipboardCheckButton bind:NSValueBinding
                                        toObject:defaultsController
                                     withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyHideAfterCopyToClipboard]
                                         options:nil];
  [self.focusSearchAfterUnlockCheckButton bind:NSValueBinding
                                      toObject:defaultsController
                                   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyFocusSearchAfterUnlock]
                                       options:nil];
//  [self.privateBrowsingCheckButton bind:NSValueBinding
//                               toObject:defaultsController
//                            withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyUsePrivateBrowsingWhenOpeningURLs]
//                                options:nil];
  
  [self.showOrHideMacPassCheckButton bind:NSValueBinding
                                      toObject:defaultsController
                                   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyShowOrHideMacPass]
                                       options:nil];
  [self.focusSearchAfterHotkey bind:NSValueBinding
                           toObject:defaultsController
                        withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyFocusSearchAfterHotkey]
                            options:nil];
  [self.focusSearchAfterHotkey bind:NSEnabledBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyShowOrHideMacPass] options:nil];

  
  self.hotkeyTextField.delegate = self;
  
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
  return NSLocalizedString(@"WORKFLOW_SETTINGS", "Label for the workflow settings tab");
}

- (void)willShowTab {
  [self _updateBrowserSelection];
  if(!_hotKey) {
    _hotKey = [DDHotKey hotKeyWithKeyData:[NSUserDefaults.standardUserDefaults dataForKey:kMPSettingsKeyShowHideKeyDataKey]];
  }
  /* Only call the setter if the hotkeys are different, otherwise the dealloc call will unregister them*/
  if(![self.hotkeyTextField.hotKey isEqual:self.hotKey]) {
    self.hotkeyTextField.hotKey = self.hotKey;
  }

}

#pragma mark -
#pragma mark Properties
- (void)setHotKey:(DDHotKey *)hotKey {
  if([self.hotKey isEqual:hotKey]) {
    NSLog(@"hotkey IS already set");
    return; // Nothing of interest has changed;
  }
  NSLog(@"hotkey set");
  _hotKey = hotKey;
  
  [NSUserDefaults.standardUserDefaults setObject:self.hotKey.keyData forKey:kMPSettingsKeyShowHideKeyDataKey];
}

- (void)_showKeyCodeMissingKeyWarning:(BOOL)show {
  self.hotkeyWarningTextField.hidden = !show;
}


#pragma mark Actions
- (void)_selectBrowser:(id)sender {
  NSString *browserBundleId = [sender representedObject];
  if(nil == browserBundleId) {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kMPSettingsKeyBrowserBundleId];
  }
  else {
    [NSUserDefaults.standardUserDefaults setObject:browserBundleId forKey:kMPSettingsKeyBrowserBundleId];
  }
  [self _updateBrowserSelection];
}

- (void)_showCustomBrowserSelection:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  NSURL *applicationURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask].firstObject;
  openPanel.directoryURL = applicationURL;
  openPanel.allowsMultipleSelection = NO;
  openPanel.canChooseDirectories = NO;
  openPanel.canChooseFiles = YES;
  openPanel.prompt = NSLocalizedString(@"SELECT_DEFAULT_BROWSER_OPEN_PANEL_SELECT_BUTTON", "Label for the select browser button on the open panel for selecting which browser to use for opening URLs");
  openPanel.message = NSLocalizedString(@"SELECT_DEFAULT_BROWSER_OPEN_PANEL_MESSAGE", "Message on the open panel for selecting which browser to use for opening URLs");
  openPanel.allowedFileTypes = @[@"app"];
  
  [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if(result == NSModalResponseOK) {
      // TODO: Autorelease pool?
      NSMenuItem *customBrowser = [[NSMenuItem alloc] init];
      customBrowser.representedObject = [NSBundle bundleWithPath:openPanel.URL.path].bundleIdentifier;
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
  self.browserPopup.menu = browserMenu;
  
  NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DEFAULT_BROWSER", "Default Browser")
                                                       action:@selector(_selectBrowser:)
                                                keyEquivalent:@""];
  defaultItem.target = self;
  [browserMenu addItem:defaultItem];
  
  NSString *currentDefaultBrowser = [NSUserDefaults.standardUserDefaults objectForKey:kMPSettingsKeyBrowserBundleId];
  NSMenuItem *selectedItem = defaultItem;
  
  [browserMenu addItem:[NSMenuItem separatorItem]];
  
  for(NSString *bundleIdentifier in [self _bundleIdentifierForHTTPS]) {
    NSString *bundlePath = [NSWorkspace.sharedWorkspace absolutePathForAppBundleWithIdentifier:bundleIdentifier];
    NSString *browserName = [NSFileManager.defaultManager displayNameAtPath:bundlePath];
    if(nil == bundlePath || nil == browserName) {
      continue; // Skip missing Applications
    }
    NSMenuItem *browserItem = [[NSMenuItem alloc] initWithTitle:browserName
                                                         action:@selector(_selectBrowser:)
                                                  keyEquivalent:@""];
    browserItem.representedObject = bundleIdentifier;
    browserItem.target = self;
    [browserMenu addItem:browserItem];
    
    if ([bundleIdentifier isEqualToString:currentDefaultBrowser]) {
      selectedItem = browserItem;
    }
  }
  
  if(browserMenu.itemArray.count > 2) {
    [browserMenu addItem:[NSMenuItem separatorItem]];
  }
  
  if(currentDefaultBrowser != nil && selectedItem == defaultItem) {
    NSString *bundlePath = [NSWorkspace.sharedWorkspace absolutePathForAppBundleWithIdentifier:currentDefaultBrowser];
    if(bundlePath != nil) {
      NSString *browserName = [NSFileManager.defaultManager displayNameAtPath:bundlePath];
      NSMenuItem *browserItem = [[NSMenuItem alloc] initWithTitle:browserName
                                                           action:@selector(_selectBrowser:)
                                                    keyEquivalent:@""];
      browserItem.representedObject = currentDefaultBrowser;
      browserItem.target = self;
      [browserMenu addItem:browserItem];
      
      selectedItem = browserItem;
    }
  }
  
  NSMenuItem *selectOtherBrowserItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OTHER_BROWSER", "Select Browser")
                                                                  action:@selector(_showCustomBrowserSelection:)
                                                           keyEquivalent:@""];
  selectOtherBrowserItem.target = self;
  [browserMenu addItem:selectOtherBrowserItem];
  [self.browserPopup selectItem:selectedItem];
}

- (NSArray *)_bundleIdentifierForHTTPS {
  NSArray *browserBundles = CFBridgingRelease(LSCopyAllHandlersForURLScheme(CFSTR("https")));
  return browserBundles;
}

- (void)controlTextDidChange:(NSNotification *)obj {
  BOOL validHotKey = self.hotkeyTextField.hotKey.valid;
  [self _showKeyCodeMissingKeyWarning:!validHotKey];
  if(validHotKey) {
    self.hotKey = self.hotkeyTextField.hotKey;
  }
}




@end
