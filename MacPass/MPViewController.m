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
  if(self.view && [self.view nextResponder] != self) {
    NSResponder *nextResponder = [[self view] nextResponder];
    [[self view] setNextResponder:self];
    [self setNextResponder:nextResponder];
  }
}

#pragma mark Binding observation
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"representedObject."]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPViewControllerWillChangeValueForRepresentedObjectKeyPathNotification object:self];
    [self willChangeValueForRepresentedObjectKeyPath:keyPath];
    [super setValue:value forKeyPath:keyPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:MPViewControllerDidChangeValueForRepresentedObjectKeyPathNotification object:self];
    [self didChangeValueForRepresentedObjectKeyPath:keyPath];
  }
  else {
    [super setValue:value forKeyPath:keyPath];
  }
}

- (void)willChangeValueForRepresentedObjectKeyPath:(NSString *)keyPath {
  NSLog(@"[%@ willChangeValueForRepresentedObjectKeyPath:%@]", NSStringFromClass([self class]), keyPath);
}

- (void)didChangeValueForRepresentedObjectKeyPath:(NSString *)keyPath {
  NSLog(@"[%@ didChangeValueForRepresentedObjectKeyPath:%@]", NSStringFromClass([self class]), keyPath);
}

@end
