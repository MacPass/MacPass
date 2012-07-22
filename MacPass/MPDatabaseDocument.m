//
//  MPDocument.m
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseDocument.h"
#import "KdbLib.h"

NSString *const MPDidLoadDataBaseNotification = @"DidLoadDataBaseNotification";

@interface MPDatabaseDocument ()
@property (retain) KdbTree *tree;
@end

@implementation MPDatabaseDocument

@synthesize tree = _tree;

- (id)init {
  // no appropriate init method
  return nil;
}

- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key
{
  self = [super init];
  if (self) {
    [self openFile:file password:password keyfile:key];
  }
  return self;
}

- (void)openFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key {
  // Try to load the file
  KdbPassword *kdbPassword = nil;
  if( password != nil ) {
    if( key != nil ) {
      kdbPassword = [[KdbPassword alloc] initWithPassword:password encoding:NSUTF8StringEncoding keyfile:[key path]];
    }
    else {
      kdbPassword = [[KdbPassword alloc] initWithPassword:password encoding:NSUTF8StringEncoding];
    }
  }
  
  @try {
    _tree = [KdbReaderFactory load:[file path] withPassword:kdbPassword];
  }
  @catch (NSException *exception) {
    // ignore
  }
  if( _tree != nil) {
    // Post notification that a new document was loaded
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:MPDidLoadDataBaseNotification object:self];
  }
}

@end
