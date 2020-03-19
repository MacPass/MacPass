//
//  MPPathControl.m
//  MacPass
//
//  Created by Michael Starke on 28.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathControl.h"
#import "MPPathControl+Private.h"

#import "MPPathCell.h"

NSString *const MPPathControlDidSetURLNotification = @"MPPathControlDidSetURLNotification";

@implementation MPPathControl

+ (Class)cellClass{
  return MPPathCell.class;
}

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
  [self _setupCell];
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  /* FIXME: this doesn't work well anymore. Need more work, see: https://www.mikeash.com/pyblog/custom-nscells-done-right.html */
  self = [super initWithCoder:coder];
    self.delegate = self;
  [self _setupCell];
  return self;
}

- (void)_setupCell {
  if([self.cell isKindOfClass:MPPathCell.class]) {
    return;
  }
  NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:self.cell];
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archive];
  self.cell = [[MPPathCell alloc] initWithCoder:unarchiver];
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
  [panel beginWithCompletionHandler:^(NSModalResponse result) {
    if(result == NSModalResponseOK) {
      self.URL = panel.URLs.firstObject;
    }
  }];
}

- (void)pathControl:(NSPathControl *)pathControl willPopUpMenu:(NSMenu *)menu {
  if(pathControl != self) {
    return;
  }
  if(@available(macOS 10.11, *)) {
    // skip
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

- (void)_postDidSetURLNotification {
  [NSNotificationCenter.defaultCenter postNotificationName:MPPathControlDidSetURLNotification object:self];
}

@end
