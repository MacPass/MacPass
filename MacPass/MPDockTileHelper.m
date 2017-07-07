//
//  MPDockTileHelper.m
//  MacPass
//
//  Created by Michael Starke on 27/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDockTileHelper.h"
#import "MPPasteBoardController.h"

@interface MPDockTileHelper () {
  BOOL _pasteboardCleard;
}

@property (assign) NSTimeInterval timeStamp;

@end

@implementation MPDockTileHelper

- (instancetype)init {
  self = [super init];
  if (self) {
    MPPasteBoardController *controller = [MPPasteBoardController defaultController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCopyToPastboard:) name:MPPasteBoardControllerDidCopyObjects object:controller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClearPasteboard:) name:MPPasteBoardControllerDidClearClipboard object:controller];
  }
  return self;
}

- (void)didCopyToPastboard:(NSNotification *)notification {
  self.timeStamp = [NSDate timeIntervalSinceReferenceDate];
  _pasteboardCleard = NO;
  if([MPPasteBoardController defaultController].clearTimeout > 0) {
    [self updateBadge];
  }
}

- (void)didClearPasteboard:(NSNotification *)notification {
  _pasteboardCleard = YES;
  if([MPPasteBoardController defaultController].clearTimeout > 0) {
    [[NSApp dockTile] setBadgeLabel:NSLocalizedString(@"CLEARING_PASTEBOARD","")];
  }
  [self performSelector:@selector(clearBadge) withObject:nil afterDelay:1];
}

- (void)clearBadge {
  [[NSApp dockTile] setBadgeLabel:nil];
}

- (void)updateBadge {
  if(_pasteboardCleard) {
    return;
  }
  NSTimeInterval timeOut = [MPPasteBoardController defaultController].clearTimeout;
  NSTimeInterval countDown = timeOut - ([NSDate timeIntervalSinceReferenceDate] - self.timeStamp);
  if(countDown > 0) {
    [[NSApp dockTile] setBadgeLabel:[[NSString alloc] initWithFormat:@"%d", (int)countDown]];
    [self performSelector:@selector(updateBadge) withObject:nil afterDelay:1];
  }
}

@end
