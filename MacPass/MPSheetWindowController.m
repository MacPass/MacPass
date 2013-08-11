//
//  MPSheetWindowController.m
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSheetWindowController.h"

@implementation MPSheetWindowController

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if(self) {
    _isDirty = YES;
  }
  return self;
}

- (NSWindow *)window {
  NSWindow *window = [super window];
  [self updateView];
  return window;
}

- (void)updateView {
  // do nothing
}

- (void)dismissSheet:(NSInteger)returnCode {
  self.isDirty = YES;
  [NSApp endSheet:[super window] returnCode:returnCode];
  [[super window] orderOut:self];
}
@end
