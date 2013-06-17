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
#import "KdbGroup+Undo.h"
#import "KdbGroup+KVOAdditions.h"
#import "KdbEntry+Undo.h"

NSString *const MPDocumentDidAddGroupNotification = @"MPDocumentDidAddGroupNotification";
NSString *const MPDocumentWillDelteGroupNotification = @"MPDocumentDidDelteGroupNotification";
NSString *const MPDocumentDidAddEntryNotification = @"MPDocumentDidAddEntryNotification";
NSString *const MPDocumentWillDeleteEntryNotification = @"MPDocumentDidDeleteEntryNotification";

NSString *const MPDocumentEntryKey = @"MPDocumentEntryKey";
NSString *const MPDocumentGroupKey = @"MPDocumentGroupKey";


@interface MPDocument ()

@property (assign, nonatomic) BOOL isProtected;
@property (retain) KdbTree *tree;
@property (nonatomic, readonly) KdbPassword *passwordHash;
@property (assign) MPDatabaseVersion version;
@property (assign) BOOL isDecrypted;

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
    _isProtected = NO;
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
  @try {
    [KdbWriterFactory persist:self.tree file:[url path] withPassword:self.passwordHash];
  }
  @catch (NSException *exception) {
    NSLog(@"%@", [exception description]);
    return NO;
  }
  
  return YES;
  
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  self.isDecrypted = NO;
  return YES;
}

- (BOOL)isEntireFileLoaded {
  return _isDecrypted;
}

- (BOOL)decryptWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL {
  self.password = password;
  @try {
    self.tree = [KdbReaderFactory load:[[self fileURL] path] withPassword:self.passwordHash];
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

- (void)setPassword:(NSString *)password {
  if(![_password isEqualToString:password]) {
    [_password release];
    _password = [password retain];
    self.isProtected = ([_password length] > 0);
  }
}

- (void)setKey:(NSURL *)key {
  if(![[_key absoluteString] isEqualToString:[key absoluteString]]) {
    [_key release];
    _key = [key retain];
    self.isProtected = (_key != nil);
  }
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
  [parent addEntryUndoable:newEntry];
  NSDictionary *userInfo = @{ MPDocumentEntryKey : newEntry };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidAddEntryNotification object:self userInfo:userInfo];
  return newEntry;
}

- (KdbGroup *)createGroup:(KdbGroup *)parent {
  KdbGroup *newGroup = [self.tree createGroup:parent];
  newGroup.name = NSLocalizedString(@"DEFAULT_GROUP_NAME", @"Title for a newly created group");
  [parent addGroupUndoable:newGroup];
  NSDictionary *userInfo = @{ MPDocumentGroupKey : newGroup };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidAddGroupNotification object:self userInfo:userInfo];
  return newGroup;
}

- (void)moveGroup:(KdbGroup *)group toGroup:(KdbGroup *)target index:(NSInteger)index {
  NSInteger oldIndex = [group.parent.groups indexOfObject:group];
  if(group.parent == target && oldIndex == index) {
    return; // No changes
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveGroup:group toGroup:group.parent index:oldIndex];
  [[self undoManager] setActionName:@"MOVE_GROUP"];
  [group.parent removeObjectFromGroupsAtIndex:oldIndex];
  if(index < 0 || index > [target.groups count] ) {
    index = [target.groups count];
  }
  [target insertObject:group inGroupsAtIndex:index];
}

- (BOOL)group:(KdbGroup *)group isMoveableToGroup:(KdbGroup *)target {
  if(target == nil) {
    return NO;
  }
  BOOL isMovable = YES;
  KdbGroup *ancestor = target.parent;
  while(ancestor.parent) {
    if(ancestor == group) {
      isMovable = NO;
      break;
    }
    ancestor = ancestor.parent;
  }
  return isMovable;
}

- (void)moveEntry:(KdbEntry *)entry toGroup:(KdbGroup *)target index:(NSInteger)index {
  NSInteger oldIndex = [entry.parent.entries indexOfObject:entry];
  if(entry.parent == target && oldIndex == index) {
    return; // No changes
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveEntry:entry toGroup:entry.parent index:oldIndex];
  [[self undoManager] setActionName:@"MOVE_ENTRY"];
  [entry.parent removeObjectFromEntriesAtIndex:oldIndex];
  if(index < 0 || index > [target.groups count] ) {
    index = [target.groups count];
  }
  [target insertObject:entry inEntriesAtIndex:index];
}

@end
