//
//  MPTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 30.06.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPTabViewController.h"

@interface MPTabViewController ()
@property (strong) NSMutableDictionary<NSString *, NSValue*> *tabViewSizes;
@end

@implementation MPTabViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _tabViewSizes = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _tabViewSizes = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  [super tabView:tabView didSelectTabViewItem:tabViewItem];
  [self _resizeWindowToFitTabView:tabViewItem];
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  [super tabView:tabView willSelectTabViewItem:tabViewItem];
  if(tabViewItem.view) {
    self.tabViewSizes[tabViewItem.identifier] = @(tabViewItem.view.frame.size);
  }
}


- (void)_resizeWindowToFitTabView:(NSTabViewItem *)tabViewItem {
  NSSize size = self.tabViewSizes[tabViewItem.identifier].sizeValue;
  NSWindow *window = self.view.window;
  
  NSRect contentRect = NSMakeRect(0, 0, size.width, size.height);
  NSRect contentFrame = [window frameRectForContentRect:contentRect];
  CGFloat toolbarHeight = CGRectGetHeight(window.frame) - CGRectGetHeight(contentFrame);
  NSPoint newOrigin = NSMakePoint(CGRectGetMinX(window.frame), CGRectGetMinY(window.frame) + toolbarHeight);
  NSRect newFrame = NSMakeRect(newOrigin.x,newOrigin.y, CGRectGetWidth(contentFrame), CGRectGetHeight(contentFrame));
  [window setFrame:newFrame display:NO animate:YES];
}

@end
