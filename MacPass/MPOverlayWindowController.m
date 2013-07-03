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
    sharedInstance = [[MPOverlayWindowController alloc] initWithWindowNibName:@"OverlayWindow"];
  });
  return sharedInstance;
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
  [self.window setHasShadow:NO];
  [[self.textField cell] setBackgroundStyle:NSBackgroundStyleLowered];
  [[self.imageView cell] setBackgroundStyle:NSBackgroundStyleLowered];
  [[self.imageView cell] setImageAlignment:NSImageAlignCenter];
}

- (void)displayOverlayImage:(NSImage *)imageOrNil label:(NSString *)labelOrNil atView:(NSView *)view {
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
    NSWindow *parentWindow = [view window];
    NSRect parentFrame = [parentWindow frame];
    NSRect myFrame = [self.window frame];
    NSPoint newOrigin = parentFrame.origin;
    newOrigin.x += 0.5 * (parentFrame.size.width - myFrame.size.width);
    newOrigin.y += 0.5 * (parentFrame.size.height - myFrame.size.height);
    [self.window setFrameOrigin:newOrigin];
    [parentWindow addChildWindow:self.window ordered:NSWindowAbove];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = 0.2;
      [[self.window animator]setAlphaValue:1];
    } completionHandler:^{
      [self.window performSelector:@selector(close) withObject:nil afterDelay:0.5];
    }];

  }
}

@end
