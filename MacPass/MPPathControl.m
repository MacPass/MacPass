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
  return TRUE;
}

- (BOOL)acceptsFirstResponder {
  return TRUE;
}

- (BOOL)becomeFirstResponder {
  [self.delegate performSelector:@selector(pathControlDidBecomeKey:) withObject:self];
  return TRUE;
}

@end
