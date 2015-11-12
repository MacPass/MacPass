//
//  NSApplication+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 10/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "NSApplication+MPAdditions.h"

@implementation NSApplication (MPAdditions)

- (NSString *)applicationName {
  return [[NSBundle mainBundle].infoDictionary[@"CFBundleName"] copy];
}

- (NSURL *)applicationSupportDirectoryURL {
  return [self applicationSupportDirectoryURL:NO];
}

- (NSURL *)applicationSupportDirectoryURL:(BOOL)create {
  NSError *error;
  NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                      inDomain:NSUserDomainMask
                                             appropriateForURL:nil
                                                        create:NO
                                                         error:&error];
  if(url) {
    url = [url URLByAppendingPathComponent:self.applicationName isDirectory:YES];
    if(create) {
      [[NSFileManager defaultManager] createDirectoryAtURL:url
                               withIntermediateDirectories:YES
                                                attributes:nil
                                                     error:&error];
    }
    return url;
  }
  return nil;
}

@end
