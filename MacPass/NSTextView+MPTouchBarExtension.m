//
//  MP.m
//  MacPass
//
//  Created by Veit-Hendrik Schlenker on 23.12.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "NSTextView+MPTouchBarExtension.h"

@implementation NSTextView (TouchBarExtension)

- (NSTouchBar *) makeTouchBar {
  NSWindow *window = [self window];
  NSTouchBar *touchBar = [window makeTouchBar];
  return touchBar;
}

@end
