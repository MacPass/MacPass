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

@property (copy) NSString *pasteData;

@end

@implementation MPAutotypePaste

- (instancetype)initWithString:(NSString *)aString {
  self = [super init];
  if(self) {
    self.pasteData = aString;
  }
  return self;
}

- (NSString *)description {
  return [[NSString alloc] initWithFormat:@"%@ paste:%@", [self class], self.pasteData];
}

- (void)appendString:(NSString *)aString {
  self.pasteData = [self.pasteData stringByAppendingString:aString];
}

- (void)execute {
  if([self.pasteData length] > 0) {
    MPPasteBoardController *controller = [MPPasteBoardController defaultController];
    [controller stashObjects];
    [controller copyObjectsWithoutTimeout:@[self.pasteData]];
    [self sendPasteKeyCode];
    usleep(0.1 * NSEC_PER_MSEC); // on 10.10 we need to wait a bit before restoring the pasteboard contents
    [controller restoreObjects];
  }
}

- (BOOL)isValid {
  /* Pasting shoudl always be valid */
  return YES;
}



@end
