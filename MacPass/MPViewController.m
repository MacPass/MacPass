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
  if(self.view && self.view.nextResponder != self) {
    NSResponder *nextResponder = self.view.nextResponder;
    self.view.nextResponder = self;
    self.nextResponder = nextResponder;
  }
}

#pragma mark NSEditorRegistration
- (void)objectDidBeginEditing:(id)editor {
  [self.windowController.document objectDidBeginEditing:editor];
  [super objectDidBeginEditing:editor];
}

- (void)objectDidEndEditing:(id)editor {
  [self.windowController.document objectDidEndEditing:editor];
  [super objectDidEndEditing:editor];
}

#pragma mark Binding observation
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"representedObject."]) {
    [self.observer willChangeModelProperty];
    [super setValue:value forKeyPath:keyPath];
    [self.observer didChangeModelProperty];
  }
  else {
    [super setValue:value forKeyPath:keyPath];
  }
}

@end
