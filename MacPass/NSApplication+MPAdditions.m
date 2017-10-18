//
//  NSApplication+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 10/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
