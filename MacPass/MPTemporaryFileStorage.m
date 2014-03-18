;//
 //  MPTemporaryFileStorage.m
 //  MacPass
 //
 //  Created by Michael Starke on 18/03/14.
 //  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
 //

#import "MPTemporaryFileStorage.h"
#import "KPKBinary.h"

#import <QuickLook/QuickLook.h>

@interface MPTemporaryFileStorage ()

@property (strong) KPKBinary *binary;

@end

@implementation MPTemporaryFileStorage

- (instancetype)initWithBinary:(KPKBinary *)binary {
  self = [super init];
  if(self) {
    _binary = binary;
  }
  return self;
}

- (void)quicklook {
  
  NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], self.binary.name];
  NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
  
  NSError *error;
  BOOL success = [self.binary.data writeToURL:fileURL options:0 error:&error];
  if(!success) {
    if(error) {
      [NSApp presentError:error];
    }
    return;
  }

  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:@"srm"];
  [task setArguments:@[@"-m", fileName]];
}


@end
