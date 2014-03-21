//
//  MPAutotypePaste.m
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypePaste.h"
#import "MPPasteBoardController.h"

#import "NSString+Commands.h"

@interface MPAutotypePaste ()

@property (strong) NSString *pasteData;

@end

@implementation MPAutotypePaste

- (instancetype)initWithString:(NSString *)aString {
  self = [super init];
  if(self) {
    self.pasteData = aString;
  }
  return self;
}

- (void)execute {
  [NSThread isMainThread] ? NSLog(@"MainThread") : NSLog(@"NonMainThread");
  if([self.pasteData length] > 0) {
    MPPasteBoardController *controller = [MPPasteBoardController defaultController];
    [controller copyObjects:@[self.pasteData]];
    [self sendPasteKeyCode];
  }
}

- (BOOL)isValid {
  /* Pasting shoudl always be valid */
  return YES;
}

@end
