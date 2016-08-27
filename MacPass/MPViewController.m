//
//  MPViewController.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

NSString *const MPViewControllerWillChangeValueForRepresentedObjectKeyPathNotification  = @"com.hicknhack.macpass.MPViewControllerWillChangeValueForRepresentedObjectKeyPathNotification";
NSString *const MPViewControllerDidChangeValueForRepresentedObjectKeyPathNotification   = @"comt.hicknhack.macpass.MPViewControllerDidChangeValueForRepresentedObjectKeyPathNotification";

@implementation MPViewController

- (void)loadView {
  [super loadView];
  [self updateResponderChain];
  [self didLoadView];
}

- (void)didLoadView {
  // override
}

- (NSWindowController *)windowController {
  return self.view.window.windowController;
}

#pragma mark Responder Chain
- (NSResponder *)reconmendedFirstResponder {
  return nil; // override
}

- (void)updateResponderChain {
  if(self.view && self.view.nextResponder != self) {
    NSResponder *nextResponder = self.view.nextResponder;
    self.view.nextResponder = self;
    self.nextResponder = nextResponder;
  }
}

#pragma mark Binding observation
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"representedObject."]) {
    [self willChangeValueForRepresentedObjectKeyPath:keyPath];
    [super setValue:value forKeyPath:keyPath];
    [self didChangeValueForRepresentedObjectKeyPath:keyPath];
  }
  else {
    [super setValue:value forKeyPath:keyPath];
  }
}

- (void)willChangeValueForRepresentedObjectKeyPath:(NSString *)keyPath {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPViewControllerWillChangeValueForRepresentedObjectKeyPathNotification object:self];
}

- (void)didChangeValueForRepresentedObjectKeyPath:(NSString *)keyPath {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPViewControllerDidChangeValueForRepresentedObjectKeyPathNotification object:self];
}

@end
