//
//  MPDocument.m
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseDocument.h"
#import "KdbLib.h"

@interface MPDatabaseDocument ()
@property (retain) KdbTree *tree;
- (id)initWithFile:(NSURL *)file andKdbPassword:(KdbPassword *)password;
@end

@implementation MPDatabaseDocument

@synthesize tree = _tree;

- (id)initWithFile:(NSURL *)file andKeyfile:(NSURL *)keyfile {
  KdbPassword *password = [[KdbPassword alloc] initWithKeyfile:[keyfile path]];
  [self initWithFile:file andKdbPassword:password];
  [password release];
  return self;
}

- (id)initWithFile:(NSURL *)file andPassword:(NSString *)password {
  KdbPassword *kdbPassword = [[KdbPassword alloc] initWithPassword:password encoding:NSUTF8StringEncoding];
  [self initWithFile:file andKdbPassword:kdbPassword];
  [password release];
  return self;
}  

- (id)initWithFile:(NSURL *)file andKdbPassword:(KdbPassword *)password {
  self = [super init];
  if (self) {
    NSString *path = [file path];
    BOOL isReadable = [[NSFileManager defaultManager] isReadableFileAtPath:path];
    BOOL isDirectory = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    // We may need more tests
    if(isReadable && NO == isDirectory) {
      @try {
       self.tree = [KdbReaderFactory load:[file path] withPassword:password];
      }
      @catch (NSException *exception) {
        // Log the error but proceede
        NSLog(@"Could not load the Database at path:%@", file);
      }
    }
  }
  return self;
}


@end
