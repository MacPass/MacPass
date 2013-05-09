//
//  MPSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MPSettingsTab;

@interface MPSettingsWindowController : NSWindowController <NSToolbarDelegate>

- (void)showSettings;
- (void)showSettingsTabWithIdentifier:(NSString *)identifier;

@end
