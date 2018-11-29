//
//  MPPathControl.m
//  MacPass
//
//  Created by Michael Starke on 28.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathControl.h"

@implementation MPPathControl

/*- (void)willOpenMenu:(NSMenu *)menu withEvent:(NSEvent *)event  {
  if(!self.URL) {
    [menu cancelTracking];
    [self _showOpenPanel];
  };
  return;
}
*/

- (void)showOpenPanel:(id)sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  if([self.delegate respondsToSelector:@selector(pathControl:willDisplayOpenPanel:)]) {
    [self.delegate pathControl:self willDisplayOpenPanel:panel];
  }
  [panel beginWithCompletionHandler:^(NSModalResponse result) {
    if(result == NSModalResponseOK) {
      self.URL = panel.URLs.firstObject;
    }
  }];
}

@end
