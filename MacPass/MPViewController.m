//
//  MPViewController.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPDocument.h"

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
    [self didChangeValueForRepresentedObjectKeyPath:keyPath];
    [super setValue:value forKeyPath:keyPath];
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
