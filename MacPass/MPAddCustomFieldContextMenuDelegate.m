//
//  MPAddCustomFieldContextMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 05.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPAddCustomFieldContextMenuDelegate.h"
#import "KeePassKit/KeePassKit.h"

NSString *const MPHMACOTPSeedAttributeKey = @"HMACOTP-Seed";
NSString *const MPHMACOTPConfigAttributeKey = @"HMACOTP-Config";

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
}

- (void)_setupHOTPMenuItemsToMenu:(NSMenu *)menu {
  
  BOOL hasConfigAttribute = nil != [self.entry customAttributeWithKey:MPHMACOTPConfigAttributeKey];
  if(!hasConfigAttribute) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add config" action:@selector(_addHMACConfig:) keyEquivalent:@""];
    item.target = self;
    [menu addItem:item];
  }
  BOOL hasSeedAttribute = nil != [self.entry customAttributeWithKey:MPHMACOTPSeedAttributeKey];
  if(!hasSeedAttribute) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add seed" action:@selector(_addHMACSeed:) keyEquivalent:@""];
    item.target = self;
    [menu addItem:item];
  }
}

- (IBAction)_addHMACConfig:(id)sender {
  [self.entry addCustomAttribute:[[KPKAttribute alloc] initWithKey:MPHMACOTPConfigAttributeKey value:@"<config>"]];
}

- (IBAction)_addHMACSeed:(id)sender {
  [self.entry addCustomAttribute:[[KPKAttribute alloc] initWithKey:MPHMACOTPSeedAttributeKey value:@"<seed>"]];
}

@end
