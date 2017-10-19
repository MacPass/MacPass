//
//  MPPathControl.m
//  MacPass
//
//  Created by Christoph Leimbrock on 8/7/17.
//

#import "MPPathControl.h"
@implementation MPPathControl
@dynamic delegate;

- (BOOL)canBecomeKeyView {
  return YES;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)becomeFirstResponder {
  [self.delegate performSelector:@selector(pathControlDidBecomeKey:) withObject:self];
  return YES;
}

@end
