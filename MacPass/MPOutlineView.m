//
//  MPOutlineView.m
//  MacPass
//
//  Created by Michael Starke on 23.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineView.h"
#import "MPNotifications.h"

@interface MPOutlineView () {
  BOOL _didBecomeFirstResponder;
}

@end

@implementation MPOutlineView

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidMoveToSuperview {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if(self.enclosingScrollView) {
    [self _setupNotifications];
  }
}

- (void)mouseDown:(NSEvent *)theEvent {
  [super mouseDown:theEvent];
  if(_didBecomeFirstResponder) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDidActivateViewNotification
                                                        object:self
                                                      userInfo:nil];
  }
  _didBecomeFirstResponder = NO;
}

- (BOOL)becomeFirstResponder {
  _didBecomeFirstResponder = YES;
  return YES;
}

- (BOOL)resignFirstResponder {
  return [super resignFirstResponder];
}

- (void)_setupNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if(self.enclosingScrollView.contentView) {
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeFrame:) name:NSViewBoundsDidChangeNotification object:self.enclosingScrollView.contentView];
  }
}

- (void)_didChangeFrame:(NSNotification *)notification {
  NSLog(@"DidChangeFrame:%@", NSStringFromRect(self.bounds));
}

@end
