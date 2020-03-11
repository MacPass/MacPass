//
//  MPOverlayWindowController.m
//  MacPass
//
//  Created by Michael Starke on 03.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import "MPOverlayWindowController.h"
#import "MPOverlayView.h"

@interface MPOverlayWindowController ()

@property (assign) BOOL isAnimating;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *textField;

@end

@implementation MPOverlayWindowController

+ (MPOverlayWindowController *)sharedController {
  static MPOverlayWindowController *sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MPOverlayWindowController alloc] initWithWindow:nil];
  });
  return sharedInstance;
}

- (NSString *)windowNibName {
  return @"OverlayWindow";
}

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if (self) {
    // Initialization code here.
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  self.window.styleMask = NSWindowStyleMaskBorderless;
  self.window.alphaValue = 0;
  self.window.opaque = NO;
  self.window.hasShadow = YES;
  self.window.backgroundColor = NSColor.clearColor;
  
  self.textField.cell.backgroundStyle = NSBackgroundStyleLowered;
  self.imageView.cell.backgroundStyle = NSBackgroundStyleEmphasized;
  ((NSImageCell *)self.imageView.cell).imageAlignment = NSImageAlignCenter;
  if (@available(macOS 10.14, *)) {
    self.imageView.contentTintColor = NSColor.textColor;
  }
}

- (void)displayOverlayImage:(NSImage *)imageOrNil label:(NSString *)labelOrNil atView:(NSView *)view {
  if(!NSThread.currentThread.isMainThread) {
    NSAssert(NO, @"Must be called on main thread");
    return;
  }
  
  if(self.isAnimating) {
    return;
  }
  self.isAnimating = YES;
  /* make window transparent */
  
  self.window.alphaValue = 0;
  self.window.isVisible = YES;
  
  /* setup any provided images and labels*/
  self.imageView.image = imageOrNil;
  if(labelOrNil) {
    self.textField.stringValue = labelOrNil;
  }
  else {
    self.textField.stringValue = @"";
  }
  [self.textField sizeToFit];
  /*
   Center in view
   */
  if(view) {
    self.window.level = NSNormalWindowLevel;
    NSWindow *parentWindow = view.window;
    NSRect parentFrame = parentWindow.frame;
    NSRect myFrame = self.window.frame;
    NSPoint newOrigin = parentFrame.origin;
    newOrigin.x += 0.5 * (parentFrame.size.width - myFrame.size.width);
    newOrigin.y += 0.5 * (parentFrame.size.height - myFrame.size.height);
    [self.window setFrameOrigin:newOrigin];
    [parentWindow addChildWindow:self.window ordered:NSWindowAbove];
  }
  else {
    self.window.level = NSStatusWindowLevel;
    NSRect parentFrame = [NSScreen mainScreen].frame;
    NSRect myFrame = self.window.frame;
    NSPoint newOrigin = parentFrame.origin;
    newOrigin.x += 0.5 * (parentFrame.size.width - myFrame.size.width);
    newOrigin.y += 0.5 * (parentFrame.size.height - myFrame.size.height);
    [self.window setFrameOrigin:newOrigin];
  }
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    context.duration = 0.2;
    [self.window animator].alphaValue = 1;
  } completionHandler:^{
    [self performSelector:@selector(_didEndAnimation) withObject:nil afterDelay:0.5];
  }];
}

- (void)_didEndAnimation {
  self.isAnimating = NO;
  [self.window close];
}

@end
