//
//  MPDocument.m
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseDocument.h"
#import "KdbLib.h"
#import "Kdb4Node.h"
#import "Kdb3Node.h"

NSString *const MPDidLoadDatabaseNotification = @"DidLoadDataBaseNotification";

@interface MPDatabaseDocument ()

@property (retain) KdbTree *tree;
@property (retain) NSURL *file;
@property (nonatomic, readonly) KdbPassword *passwordHash;
@property (assign) MPDatabaseVersion version;

@end

@implementation MPDatabaseDocument

+ (id)documentWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key {
  return [[[MPDatabaseDocument alloc] initWithFile:file password:password keyfile:key] autorelease];
}

+ (id)documentWithNewDatabase:(MPDatabaseVersion)version {
  return  [[[MPDatabaseDocument alloc] initWithNewDatabase:version] autorelease];
}

- (id)init {
  // create empty document
  return [self initWithFile:nil password:nil keyfile:nil];
}

/*
 Initalizer for creating
 */
- (id)initWithNewDatabase:(MPDatabaseVersion)version {
  self = [super init];
  if(self) {
    switch(version) {
      case MPDatabaseVersion3:
        self.tree = [[[Kdb3Tree alloc] init] autorelease];
        break;
      case MPDatabaseVersion4:
        self.tree = [[[Kdb4Tree alloc] init] autorelease];
        break;
      default:
        [self release];
        return nil;
    }
    KdbGroup *newGroup = [self.tree createGroup:self.tree.root];
    newGroup.name = @"Default";
  }
  return self;
}

/*
 Designated initalizer for loading
 */
- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key
{
  self = [super init];
  if (self) {
    /*
     Create an empty file
     */
    self.file = file;
    self.key = key;
    self.password = password;
    @try {
      self.tree = [KdbReaderFactory load:[self.file path] withPassword:self.passwordHash];
    }
    @catch (NSException *exception) {
      NSLog(@"%@", [exception description]);
      [self release];
      return nil;
    }
    
    if([self.tree isKindOfClass:[Kdb4Tree class]]) {
      self.version = MPDatabaseVersion4;
    }
    else if( [self.tree isKindOfClass:[Kdb3Tree class]]) {
      self.version = MPDatabaseVersion3;
    }
  }
  return self;
}


- (void)dealloc
{
  self.tree = nil;
  self.file = nil;
  self.password = nil;
  self.key = nil;
  [super dealloc];
}

- (KdbGroup *)root {
  return [self.tree root];
}


- (BOOL)save {
  NSError *fileError;
  if( [self.file checkResourceIsReachableAndReturnError:&fileError] ) {
    @try {
      [KdbWriterFactory persist:self.tree file:[self.file path] withPassword:self.passwordHash];
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

- (KdbPassword *)passwordHash {
  
  // Create the password for the given parameters
  if( self.password && self.key) {
    return [[[KdbPassword alloc] initWithPassword:self.password encoding:NSUTF8StringEncoding keyfile:[self.key path]] autorelease];
  }
  
  if( self.password ) {
    return [[[KdbPassword alloc] initWithPassword:self.password encoding:NSUTF8StringEncoding] autorelease];
  }
  
  if( self.key ) {
    return [[[KdbPassword alloc] initWithKeyfile:[self.key path]] autorelease];
  }
  
  NSLog(@"Error: No password or keyfile given!");
  return nil;
}

@end
