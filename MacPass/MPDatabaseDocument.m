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
@property (readonly)BOOL isNewFile;

@end

@implementation MPDatabaseDocument

+ (id)documentWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key {
  return [[[MPDatabaseDocument alloc] initWithFile:file password:password keyfile:key] autorelease];
}

+ (id)newDocument:(MPDatabaseVersion)version {
  return  [[[MPDatabaseDocument alloc] initWithNewDatabase:version] autorelease];
}

+ (id)newDocumentAtURL:(NSURL *)url databaseVersion:(MPDatabaseVersion)dbversion password:(NSString *)password keyfile:(NSURL *)key {
  return [[[MPDatabaseDocument alloc] initNewDocumentAtURL:url databaseVersion:dbversion password:password keyfile:key] autorelease];
}

- (id)init {
  // create empty document
  return [self initWithFile:nil password:nil keyfile:nil];
}


- (id)initNewDocumentAtURL:(NSURL *)url databaseVersion:(MPDatabaseVersion)dbversion password:(NSString *)password keyfile:(NSURL *)key
{
  self = [self initWithNewDatabase:dbversion];
  if(self) {
    self.file = url;
    self.password = password;
    self.key = key;
  }
  return self;
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
  if(self.isNewFile || [self.file checkResourceIsReachableAndReturnError:&fileError] ) {
    @try {
      [KdbWriterFactory persist:self.tree file:[self.file path] withPassword:self.passwordHash];
    }
    @catch (NSException *exception) {
      NSLog(@"%@", [exception description]);
      return NO;
    }
    return YES;
  }
  else {
    NSLog(@"File Error: %@", fileError);
    return NO;
  }
}

- (BOOL)saveAsFile:(NSURL *)file withPassword:(NSString *)password keyfile:(NSURL *)key {
  self.file = file;
  self.password = password;
  self.key = key;
  return [self save];
}

- (KdbPassword *)passwordHash {
  // TODO: Use defaults to determine Encoding?
  return [[[KdbPassword alloc] initWithPassword:self.password passwordEncoding:NSUTF8StringEncoding keyFile:[self.key path]] autorelease];
}

- (KdbEntry *)createEntry:(KdbGroup *)parent {
  KdbEntry *newEntry = [self.tree createEntry:parent];
  newEntry.title = NSLocalizedString(@"DEFAULT_ENTRY_TITLE", @"Title for a newly created entry");
  [parent addEntry:newEntry];
  return newEntry;
}

- (KdbGroup *)createGroup:(KdbGroup *)parent {
  KdbGroup *newGroup = [self.tree createGroup:parent];
  newGroup.name = NSLocalizedString(@"DEFAULT_GROUP_NAME", @"Title for a newly created group");
  [parent addGroup:newGroup];
  return newGroup;
}

@end
