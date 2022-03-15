//
//  MPInspectorEditorView.m
//  MacPass
//
//  Created by Michael Starke on 08.03.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "MPInspectorEditorView.h"

NSString *const MPInspectorEditorViewMouseEnteredNotification = @"com.hicknhacksoftware.macpass.MPInspectorEditorViewMouseEnteredNotification";
NSString *const MPInspectorEditorViewMouseExitedNotification = @"com.hicknhacksoftware.macpass.MPInspectorEditorViewMouseExitedNotification";

@interface MPInspectorEditorView ()

@property (strong) NSTrackingArea *trackingArea;

@end

@implementation MPInspectorEditorView

- (void)mouseEntered:(NSEvent *)event {
  [NSNotificationCenter.defaultCenter postNotificationName:MPInspectorEditorViewMouseEnteredNotification object:self];
}

- (void)mouseExited:(NSEvent *)event {
  [NSNotificationCenter.defaultCenter postNotificationName:MPInspectorEditorViewMouseExitedNotification object:self];
}

- (void)createTrackingArea {
  self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
  [self addTrackingArea:self.trackingArea];

  NSPoint mouseLocation = self.window.mouseLocationOutsideOfEventStream;
  mouseLocation = [self convertPoint:mouseLocation fromView:nil];
  if(NSPointInRect(mouseLocation, self.bounds)) {
    [self mouseEntered:NSApp.currentEvent];
  }
  else {
    [self mouseExited:NSApp.currentEvent];
  }
}

- (void)updateTrackingAreas {
  [self removeTrackingArea:self.trackingArea];
  [self createTrackingArea];
  [super updateTrackingAreas];
}

@end
