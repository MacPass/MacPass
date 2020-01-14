//
//  MPPathCell.m
//  MacPass
//
//  Created by Michael Starke on 14.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathCell.h"
#import "MPPathControl+Private.h"

@implementation MPPathCell

- (void)setURL:(NSURL *)URL {
  super.URL = URL;
  if([self.controlView isKindOfClass:MPPathControl.class]) {
    MPPathControl *pc = (MPPathControl *)self.controlView;
    [pc _postDidSetURLNotification];
  }
}


@end
