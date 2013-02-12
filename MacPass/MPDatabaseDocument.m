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

- (id)init {
  // no appropriate init method
  return nil;
}

- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key
{
  self = [super init];
  if (self) {
    BOOL sucess = [self openFile:file password:password keyfile:key];
    // Check if load was successfull and return nil of not
    if( NO == sucess ) {
      [self release];
      return nil;
    }
  }
  return self;
}

- (BOOL) openFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key{
  // Try to load the file
  KdbPassword *dbPassword = nil;
  const BOOL hasPassword = (password != nil);
  const BOOL hasKeyfile = (key != nil);
  
  // Create the password for the given parameters
  if( hasPassword && hasKeyfile) {
    dbPassword = [[KdbPassword alloc] initWithPassword:password encoding:NSUTF8StringEncoding keyfile:[key path]];
  }
  else if( hasPassword ) {
    dbPassword = [[KdbPassword alloc] initWithPassword:password encoding:NSUTF8StringEncoding];
  }
  else if( hasKeyfile ) {
    dbPassword = [[KdbPassword alloc] initWithKeyfile:[key path]];
  }
  else {
    NSLog(@"Error: No password or keyfile given!");
    return NO;
  }
  
  @try {
    self.tree = [KdbReaderFactory load:[file path] withPassword:dbPassword];
  }
  @catch (NSException *exception) {
    NSLog(@"%@", [exception description]);
  }
  // Cleanup
  if( dbPassword != nil ) {
    [dbPassword release];
  }
  
  if( self.tree != nil) {
    return YES;
  }
  return NO;
  
}

@end
