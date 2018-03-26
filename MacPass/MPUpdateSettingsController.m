//
//  MPUpdateSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 04.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
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

#import "MPUpdateSettingsController.h"
#import <Sparkle/Sparkle.h>

@interface MPUpdateSettingsController ()
@property (weak) IBOutlet NSButton *automaticallyCheckForUpdatesCheckButton;
@property (weak) IBOutlet NSPopUpButton *checkIntervallPopupButton;

@end

@implementation MPUpdateSettingsController

- (NSString *)nibName {
  return @"UpdateSettings";
}

- (NSString *)identifier {
  return @"UpdateSettings";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameApplicationIcon];
}

- (NSString *)label {
  return NSLocalizedString(@"UPDATE_SETTINGS", @"Update Settings Label");
}

- (void)awakeFromNib {
/* only enable bindings to settings in release mode */
#if defined(DEBUG) || defined(NO_SPARKLE)
  self.checkIntervallPopupButton.enabled = NO;
  self.automaticallyCheckForUpdatesCheckButton.enabled = NO;
#else
  [self.checkIntervallPopupButton bind:NSSelectedTagBinding toObject:[SUUpdater sharedUpdater] withKeyPath:NSStringFromSelector(@selector(updateCheckInterval)) options:nil];
  [self.checkIntervallPopupButton bind:NSEnabledBinding toObject:[SUUpdater sharedUpdater] withKeyPath:NSStringFromSelector(@selector(automaticallyChecksForUpdates)) options:nil];
  [self.automaticallyCheckForUpdatesCheckButton bind:NSValueBinding toObject:[SUUpdater sharedUpdater] withKeyPath:NSStringFromSelector(@selector(automaticallyChecksForUpdates)) options:nil];
#endif
  
}

@end
