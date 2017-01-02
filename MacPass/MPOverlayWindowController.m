//
//  MPOverlayWindowController.m
//  MacPass
//
//  Created by Michael Starke on 03.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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
  [self.window setStyleMask:NSBorderlessWindowMask];
  [self.window setAlphaValue:0];
  [self.window setOpaque:NO];
  [self.window setHasShadow:YES];
  [[self.textField cell] setBackgroundStyle:NSBackgroundStyleLowered];
  [[self.imageView cell] setBackgroundStyle:NSBackgroundStyleDark];
  [[self.imageView cell] setImageAlignment:NSImageAlignCenter];
}

- (void)displayOverlayImage:(NSImage *)imageOrNil label:(NSString *)labelOrNil atView:(NSView *)view {
  if(![NSThread currentThread].isMainThread) {  NSAssert(NO, @"Must be called on main thread"); }
  /*
  if(![NSThread currentThread].isMainThread) {
    __weak MPOverlayWindowController *welf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      [welf displayOverlayImage:imageOrNil label:labelOrNil atView:view];
    });
    return;
  }
  */
  if(self.isAnimating) {
    return;
  }
  self.isAnimating = YES;
  /* make window transparent */
  
  [self.window setAlphaValue:0];
  [self.window setIsVisible:YES];
  
  /* setup any provided images and labels*/
  [self.imageView setImage:imageOrNil];
  if(labelOrNil) {
    [self.textField setStringValue:labelOrNil];
  }
  else {
    [self.textField setStringValue:@""];
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
    [[self.window animator]setAlphaValue:1];
  } completionHandler:^{
    [self performSelector:@selector(_didEndAnimation) withObject:nil afterDelay:0.5];
  }];
}

- (void)_didEndAnimation {
  self.isAnimating = NO;
  [self.window close];
}

@end
