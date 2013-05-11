//
//  MPDocument.m
//  MacPass
//
//  Created by Michael Starke on 08.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "KdbLib.h"
#import "Kdb3Node.h"
#import "Kdb4Node.h"
#import "KdbPassword.h"
#import "MPDatabaseVersion.h"

NSString *const MPDocumentDidAddGroupNotification = @"MPDocumentDidAddGroupNotification";
NSString *const MPDocumentDidDelteGroupNotification = @"MPDocumentDidDelteGroupNotification";
NSString *const MPDocumentDidAddEntryNotification = @"MPDocumentDidAddEntryNotification";
NSString *const MPDocumentDidDeleteEntryNotification = @"MPDocumentDidDeleteEntryNotification";

NSString *const MPDocumentEntryKey = @"MPDocumentEntryKey";
NSString *const MPDocumentGroupKey = @"MPDocumentGroupKey";


@interface MPDocument ()

@property (retain) KdbTree *tree;
@property (retain) NSURL *file;
@property (nonatomic, readonly) KdbPassword *passwordHash;
@property (assign) MPDatabaseVersion version;
@property (assign) BOOL isDecrypted;
@property (assign) BOOL isDirty;

@end


@implementation MPDocument

- (id)init
{
  return [self initWithVersion:MPDatabaseVersion4];
}

- (id)initWithVersion:(MPDatabaseVersion)version {
  self = [super init];
  if(self) {
    _isDecrypted = YES;
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
    self.tree.root = newGroup;
  }
  return self;
}

- (void) makeWindowControllers {
  MPDocumentWindowController *windowController = [[MPDocumentWindowController alloc] init];
  [self addWindowController:windowController];
  [windowController release];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  self.file = url;
  
  @try {
    [KdbWriterFactory persist:self.tree file:[self.file path] withPassword:self.passwordHash];
  }
  @catch (NSException *exception) {
    NSLog(@"%@", [exception description]);
    return NO;
  }
  
  return YES;
  
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  self.file = url;
  self.isDecrypted = NO;
  return YES;
}

- (BOOL)isEntireFileLoaded {
  return _isDecrypted;
}

- (BOOL)decryptWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL {
  self.key = keyFileURL;
  self.password = password;
  @try {
    self.tree = [KdbReaderFactory load:[self.file path] withPassword:self.passwordHash];
  }
  @catch (NSException *exception) {
    NSLog(@"%@", [exception description]);
    return NO;
  }
  
  if([self.tree isKindOfClass:[Kdb4Tree class]]) {
    self.version = MPDatabaseVersion4;
  }
  else if( [self.tree isKindOfClass:[Kdb3Tree class]]) {
    self.version = MPDatabaseVersion3;
  }
  _isDecrypted = YES;
  return YES;
}

- (KdbPassword *)passwordHash {
  // TODO: Use defaults to determine Encoding?
  return [[[KdbPassword alloc] initWithPassword:self.password passwordEncoding:NSUTF8StringEncoding keyFile:[self.key path]] autorelease];
}

+ (BOOL)autosavesInPlace
{
  return NO;
}

- (KdbGroup *)root {
  return [self.tree root];
}

- (KdbEntry *)createEntry:(KdbGroup *)parent {
  KdbEntry *newEntry = [self.tree createEntry:parent];
  newEntry.title = NSLocalizedString(@"DEFAULT_ENTRY_TITLE", @"Title for a newly created entry");
  [[self undoManager] registerUndoWithTarget:self selector:@selector(deleteEntry:) object:newEntry];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_ENTRY", @"Create Entry Undo")];
  [parent addEntry:newEntry];
  return newEntry;
}

- (KdbGroup *)createGroup:(KdbGroup *)parent {
  KdbGroup *newGroup = [self.tree createGroup:parent];
  newGroup.name = NSLocalizedString(@"DEFAULT_GROUP_NAME", @"Title for a newly created group");
  
  [[self undoManager] registerUndoWithTarget:self selector:@selector(deleteGroup:) object:newGroup];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_GROUP", @"Create Group Undo")];
  [parent addGroup:newGroup];
  NSDictionary *userInfo = @{ MPDocumentGroupKey:newGroup };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidAddGroupNotification object:self userInfo:userInfo];
  self.isDirty = YES;
	  
  return newGroup;
}

- (void)addGroup:(NSArray *)groupAndParent{
  KdbGroup *parent = groupAndParent[0];
  KdbGroup *group = groupAndParent[1];
  NSDictionary *userInfo = @{ MPDocumentGroupKey:group };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidAddGroupNotification object:self userInfo:userInfo];
  [parent addGroup:group];
}

- (void)deleteEntry:(KdbEntry *)entry {
  if(entry.parent) {
    [entry.parent removeEntry:entry];
    self.isDirty = YES;
  }
}

- (void)deleteGroup:(KdbGroup *)group {
  if(group.parent) {
    [[self undoManager] registerUndoWithTarget:self selector:@selector(addGroup:) object:@[group.parent, group]];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_GROUP", @"Create Group Undo")];
    [group.parent removeGroup:group];
    NSDictionary *userInfo = @{ MPDocumentEntryKey:group };
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidDelteGroupNotification object:self userInfo:userInfo];
    
    self.isDirty = YES;
  }
}


@end
