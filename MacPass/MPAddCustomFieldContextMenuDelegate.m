//
//  MPAddCustomFieldContextMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 05.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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

#import "MPAddCustomFieldContextMenuDelegate.h"
#import "KeePassKit/KeePassKit.h"

#import "KPKEntry+OTP.h"

/*
HmacOtp-Secret (the UTF-8 representation of the value is the secret),
HmacOtp-Secret-Hex (secret as hex string),
HmacOtp-Secret-Base32 (secret as Base32 string)
HmacOtp-Secret-Base64 (secret as Base64 string)
 
HmacOtp-Counter field.
*/

@interface MPAddCustomFieldContextMenuDelegate ()
@property (readonly, nonatomic) KPKEntry *entry;
@end

@implementation MPAddCustomFieldContextMenuDelegate

- (KPKEntry *)entry {
  KPKEntry *entry = self.viewController.representedObject;
  if([entry isKindOfClass:KPKEntry.class]) {
    return entry;
  }
  return nil;
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
  [menu removeAllItems];
  [self _setupHOTPMenuItemsToMenu:menu];
  [self _setupTOTPMenuItemsToMenu:menu];
}

/* HMAC OTP */
- (void)_setupHOTPMenuItemsToMenu:(NSMenu *)menu {
  BOOL hasConfigAttribute = nil != [self.entry customAttributeWithKey:MPHMACOTPConfigAttributeKey];
  if(!hasConfigAttribute) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_CUSTOM_ATTRIBUTE_HMACOTP_CONFIG", @"Menu item title for adding an hmacotp config attribute") action:@selector(_addHMACConfig:) keyEquivalent:@""];
    item.target = self;
    [menu addItem:item];
  }
  BOOL hasSeedAttribute = nil != [self.entry customAttributeWithKey:MPHMACOTPSeedAttributeKey];
  if(!hasSeedAttribute) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_CUSTOM_ATTRIBUTE_HMACOTP_SEED", @"Menu item title for adding an hmacotp seed attribute") action:@selector(_addHMACSeed:) keyEquivalent:@""];
    item.target = self;
    [menu addItem:item];
  }
}
- (IBAction)_setupHMACConfig:(id)sender {}
- (IBAction)_delteHMACConfig:(id)sender {}

- (IBAction)_addHMACConfig:(id)sender {
  [self.entry addCustomAttribute:[[KPKAttribute alloc] initWithKey:MPHMACOTPConfigAttributeKey value:@"<config>"]];
}

- (IBAction)_addHMACSeed:(id)sender {
  [self.entry addCustomAttribute:[[KPKAttribute alloc] initWithKey:MPHMACOTPSeedAttributeKey value:@"<seed>"]];
}

/* Time OPT*/
- (void)_setupTOTPMenuItemsToMenu:(NSMenu *)menu {
  BOOL hasTOTPAuthAttribute = nil != [self.entry customAttributeWithKey:MPTOTPAuthAttributeKey];
  BOOL hasTOTPSeedAttribute = nil != [self.entry customAttributeWithKey:MPTOTPSeedAttributeKey];
  BOOL hasTOTPSettingsAttribute = nil != [self.entry customAttributeWithKey:MPTOTPSeedAttributeKey];
  
  
  BOOL hasValidSettings = hasTOTPAuthAttribute || (hasTOTPSeedAttribute && hasTOTPSettingsAttribute);
  if(hasValidSettings) {
    // Edit
    NSMenuItem *editItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"EDIT_TOTP_SETTINGS", @"Menu item title editing TOTP settings") action:@selector(_editTOTPSettings:) keyEquivalent:@""];
    editItem.target = self;
    [menu addItem:editItem];
    // Delete
    NSMenuItem *deleteItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE_TOTP_SETTINGS", @"Menu item title for deleting TOTP settings") action:@selector(_deleteTOTPSettings:) keyEquivalent:@""];
    deleteItem.target = self;
    [menu addItem:deleteItem];
  }
  else {
    // Setup
    NSMenuItem *setupItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SETUP_TOTP_SETTINGS", @"Menu item title editing TOTP settings") action:@selector(_setupTOTPSettings:) keyEquivalent:@""];
    setupItem.target = self;
    [menu addItem:setupItem];

  }
}

- (IBAction)_setupTOTPSettings:(id)sender {}
- (IBAction)_editTOTPSettings:(id)sender {}
- (IBAction)_deleteTOTPSettings:(id)sender {}

@end
