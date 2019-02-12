//
//  MPDockTileHelper.m
//  MacPass
//
//  Created by Michael Starke on 27/03/14.
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

#import "MPDockTileHelper.h"
#import "MPPasteBoardController.h"

@interface MPDockTileHelper () {
  BOOL _pasteboardCleard;
  NSTimeInterval _timeStamp;
}

@end

@implementation MPDockTileHelper

- (instancetype)init {
  self = [super init];
  if (self) {
    MPPasteBoardController *controller = [MPPasteBoardController defaultController];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didCopyToPastboard:) name:MPPasteBoardControllerDidCopyObjects object:controller];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didClearPasteboard:) name:MPPasteBoardControllerDidClearClipboard object:controller];
  }
  return self;
}

- (void)didCopyToPastboard:(NSNotification *)notification {
  _timeStamp = NSDate.timeIntervalSinceReferenceDate;
  _pasteboardCleard = NO;
  if(MPPasteBoardController.defaultController.clearTimeout > 0) {
    [self updateBadge];
  }
}

- (void)didClearPasteboard:(NSNotification *)notification {
  _pasteboardCleard = YES;
  if([MPPasteBoardController defaultController].clearTimeout > 0) {
    NSApp.dockTile.badgeLabel = NSLocalizedString(@"CLEARING_PASTEBOARD", "String displayed at dock badge when clipboard is about to be cleared");
  }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self clearBadge];
  });
}

- (void)clearBadge {
  NSApp.dockTile.badgeLabel = nil;
}

- (void)updateBadge {
  if(_pasteboardCleard) {
    return;
  }
  NSTimeInterval timeOut = MPPasteBoardController.defaultController.clearTimeout;
  NSTimeInterval countDown = timeOut - (NSDate.timeIntervalSinceReferenceDate - _timeStamp);
  if(countDown > 0) {
    NSApp.dockTile.badgeLabel = [[NSString alloc] initWithFormat:@"%d", (int)countDown];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self updateBadge];
    });
  }
}

@end
