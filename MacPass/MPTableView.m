//
//  MPTableView.m
//  MacPass
//
//  Created by Michael Starke on 07.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPTableView.h"

@implementation MPTableView

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
  /*
   We need to clear the outer areas
   as calling super will not do that for us
   */
  [[NSColor whiteColor] set];
  NSRectFill(clipRect);
  [super drawBackgroundInClipRect:clipRect];
}
@end
