//
//  MPDatabaseController.m
//  MacPass
//
//  Created by michael starke on 13.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseController.h"
#import "MPDatabaseDocument.h"

@interface MPDatabaseController ()

@property (retain) MPDatabaseDocument *database;

@end

@implementation MPDatabaseController

+ (MPDatabaseController *)defaultController {
  static MPDatabaseController *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MPDatabaseController alloc] init];
  });
  
  return sharedInstance;
}

- (id)init
{
  self = [super init];
  if (self) {
    // nothing to do;
  }
  return self;
}

- (MPDatabaseDocument *)createDatabase:(MPDatabaseVersion)version password:(NSString *)password keyfile:(NSURL *)key {
  
  return self.database;
}

- (MPDatabaseDocument *)openDatabase:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key {
  self.database = [MPDatabaseDocument documentWithFile:file password:password keyfile:key];
  return self.database;
}

@end
