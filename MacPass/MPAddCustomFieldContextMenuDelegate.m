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
  
}
- (IBAction)_setupHMACConfig:(id)sender {
  
}
- (IBAction)_delteHMACConfig:(id)sender {
  
}

/* Time OPT*/
- (void)_setupTOTPMenuItemsToMenu:(NSMenu *)menu {
  NSMenuItem *setupItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SETUP_TOTP_SETTINGS", @"Menu item title editing TOTP settings") action:@selector(_setupTOTPSettings:) keyEquivalent:@""];
  setupItem.target = self;
  [menu addItem:setupItem];
}

- (IBAction)_setupTOTPSettings:(id)sender {}
- (IBAction)_deleteTOTPSettings:(id)sender {}

@end
