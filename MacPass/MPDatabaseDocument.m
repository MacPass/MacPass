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
@property (retain) NSURL *file;
@property (retain) KdbPassword *password;
@end

@implementation MPDatabaseDocument

+ (id)documentWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key {
  return [[[MPDatabaseDocument alloc] initWithFile:file password:password keyfile:key] autorelease];
}

- (id)init {
  // create empty document
  return [self initWithFile:nil password:nil keyfile:nil];
}
/*
 Designated initalizeder
 */
- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key
{
  self = [super init];
  if (self) {
    /*
     Create an empty file
     */
    if(!file) {
      self.tree = [[[KdbTree alloc] init] autorelease];
      self.tree.root = [[[KdbGroup alloc] init] autorelease];
      [self.tree.root setName:NSLocalizedString(@"INITIAL_GROUP", @"")];
    }
    /*
     Try to load a given file
     */
    else {
      self.file = file;
      const BOOL hasPassword = (password != nil);
      const BOOL hasKeyfile = (key != nil);
      
      // Create the password for the given parameters
      if( hasPassword && hasKeyfile) {
        self.password = [[[KdbPassword alloc] initWithPassword:password encoding:NSUTF8StringEncoding keyfile:[key path]] autorelease];
      }
      else if( hasPassword ) {
        self.password = [[[KdbPassword alloc] initWithPassword:password encoding:NSUTF8StringEncoding] autorelease];
      }
      else if( hasKeyfile ) {
        self.password = [[[KdbPassword alloc] initWithKeyfile:[key path]] autorelease];
      }
      else {
        NSLog(@"Error: No password or keyfile given!");
      }
      
      @try {
        self.tree = [KdbReaderFactory load:[self.file path] withPassword:self.password];
      }
      @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
      }
      
    }
  }
  // Test if something went wrong and nil out if so
  if( self.tree == nil) {
    [self release];
    self = nil;
  }
  return self;
}

- (BOOL)save {
  NSError *fileError;
  if( self.password && [self.file checkResourceIsReachableAndReturnError:&fileError] ) {
    @try {
    [KdbWriterFactory persist:self.tree file:[self.file path] withPassword:self.password];
    }
    @catch (NSException *exception) {
      NSLog(@"%@", [exception description]);
      return NO;
    }
    return YES;
  }
}

- (BOOL)saveAsFile:(NSURL *)file withPassword:(NSString *)password keyfile:(NSURL *)key {
  return NO;
}
@end
