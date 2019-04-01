//
//  MPPathControl.m
//  MacPass
//
//  Created by Michael Starke on 28.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathControl.h"

@implementation MPPathControl

- (BOOL)canBecomeKeyView {
  return YES;
}

- (BOOL)acceptsFirstResponder {
  /*
   documentation state YES is required when canBecomeKeyView is YES but setting to YES
   causes NSWindow to use this as first responder when closing the password generator popover
   */
  return NO;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  self.delegate = self;
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  self.delegate = self;
  return self;
}

- (void)willOpenMenu:(NSMenu *)menu withEvent:(NSEvent *)event  {
  if(!self.URL) {
    [menu cancelTracking];
    [self showOpenPanel:nil];
  };
  return;
}

- (void)showOpenPanel:(id)sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  if([self.delegate respondsToSelector:@selector(pathControl:willDisplayOpenPanel:)]) {
    [self.delegate pathControl:self willDisplayOpenPanel:panel];
  }
  NSModalResponse result = [panel runModal];
  if(result == NSModalResponseOK) {
    self.URL = panel.URLs.firstObject;
  }
}

- (void)pathControl:(NSPathControl *)pathControl willPopUpMenu:(NSMenu *)menu {
  if(pathControl != self) {
    return;
  }
  if(@available(macOS 10.11, *)) {
    NSLog(@"Skipping 10.10 pathControl:willPopUpMenu");
  }
  else {
    if(!self.URL) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [menu cancelTracking];
      });
      [self showOpenPanel:self];
    }
  }
}

- (void)pathControl:(NSPathControl *)pathControl willDisplayOpenPanel:(NSOpenPanel *)openPanel {
  openPanel.animationBehavior = NSWindowAnimationBehaviorDocumentWindow;
  openPanel.canChooseDirectories = NO;
  openPanel.allowsMultipleSelection = NO;
  openPanel.prompt = NSLocalizedString(@"CHOOSE_FILE_BUTTON_TITLE", @"Button title in the key file selection dialog for selecting a key");
}

@end
