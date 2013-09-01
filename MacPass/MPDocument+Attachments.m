//
//  MPDocument+Attachments.m
//  MacPass
//
//  Created by Michael Starke on 05.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

#import "KPKEntry.h"
#import "KPKBinary.h"

@implementation MPDocument (Attachments)

- (void)addAttachment:(NSURL *)location toEntry:(KPKEntry *)anEntry {
  NSError *error = nil;
  NSDictionary *resourceKeys = [location resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
  if([resourceKeys[ NSURLIsDirectoryKey ] boolValue] == YES ) {
    return; // We do not add whole directories
  }
  KPKBinary *binary = [[KPKBinary alloc] initWithContentsOfURL:location];
  if(binary) {
    [anEntry addBinary:binary];
  }
}

@end
