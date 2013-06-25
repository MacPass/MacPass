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
#import "KdbGroup+MPTreeTools.h"
#import "KdbEntry+Undo.h"
#import "Kdb3Tree+NewTree.h"
#import "Kdb4Tree+NewTree.h"

NSString *const MPDocumentDidAddGroupNotification = @"MPDocumentDidAddGroupNotification";
NSString *const MPDocumentWillDelteGroupNotification = @"MPDocumentDidDelteGroupNotification";
NSString *const MPDocumentDidAddEntryNotification = @"MPDocumentDidAddEntryNotification";
NSString *const MPDocumentWillDeleteEntryNotification = @"MPDocumentDidDeleteEntryNotification";

NSString *const MPDocumentEntryKey = @"MPDocumentEntryKey";
NSString *const MPDocumentGroupKey = @"MPDocumentGroupKey";


@interface MPDocument ()

@property (assign, nonatomic) BOOL secured;
@property (retain) KdbTree *tree;
@property (nonatomic, readonly) KdbPassword *passwordHash;
@property (assign) MPDatabaseVersion version;
@property (assign) BOOL decrypted;

@end


@implementation MPDocument

- (id)init
{
  return [self initWithVersion:MPDatabaseVersion4];
}
#pragma mark NSDocument essentials
- (id)initWithVersion:(MPDatabaseVersion)version {
  self = [super init];
  if(self) {
    _decrypted = YES;
    _secured = NO;
    _locked = NO;
    switch(version) {
      case MPDatabaseVersion3:
        _tree = [Kdb3Tree newTemplateTree];
        break;
      case MPDatabaseVersion4:
        _tree = [Kdb4Tree newTemplateTree];
        break;
      default:
        [self release];
        return nil;
    }
  }
  return self;
}

- (void)makeWindowControllers {
  MPDocumentWindowController *windowController = [[MPDocumentWindowController alloc] init];
  [self addWindowController:windowController];
  [windowController release];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  NSError *error = nil;
  [KdbWriterFactory persist:self.tree fileURL:url withPassword:self.passwordHash error:&error];
  if(error) {
    NSLog(@"%@", [error localizedDescription]);
    return NO;
  }
  return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
  self.decrypted = NO;
  return YES;
}

- (BOOL)isEntireFileLoaded {
  return _decrypted;
}

#pragma mark Protection
- (BOOL)decryptWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL {
  self.key = keyFileURL;
  self.password = [password length] > 0 ? password : nil;
  @try {
    self.tree = [KdbReaderFactory load:[[self fileURL] path] withPassword:self.passwordHash];
  }
  @catch (NSException *exception) {
    return NO;
  }
  
  if([self.tree isKindOfClass:[Kdb4Tree class]]) {
    self.version = MPDatabaseVersion4;
  }
  else if( [self.tree isKindOfClass:[Kdb3Tree class]]) {
    self.version = MPDatabaseVersion3;
  }
  _decrypted = YES;
  return YES;
}

- (void)setPassword:(NSString *)password {
  if(![_password isEqualToString:password]) {
    [_password release];
    _password = [password retain];
    _secured |= ([_password length] > 0);
  }
}

- (void)setKey:(NSURL *)key {
  if(![[_key absoluteString] isEqualToString:[key absoluteString]]) {
    [_key release];
    _key = [key retain];
    _secured |= (_key != nil);
  }
}

- (KdbPassword *)passwordHash {
  
  return [[[KdbPassword alloc] initWithPassword:self.password passwordEncoding:NSUTF8StringEncoding keyFileURL:self.key] autorelease];
}

+ (BOOL)autosavesInPlace
{
  return NO;
}

#pragma mark Data Accesors
- (KdbGroup *)root {
  return [self.tree root];
}

- (KdbEntry *)findEntry:(UUID *)uuid {
  return [self.root entryForUUID:uuid];
}

- (Binary *)binaryForRef:(BinaryRef *)binaryRef {
  if(self.version != MPDatabaseVersion4) {
    return nil;
  }
  NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    Binary *binaryFile = evaluatedObject;
    return (binaryFile.binaryId == binaryRef.ref);
  }];
  Kdb4Tree *tree = (Kdb4Tree *)self.tree;
  NSArray *filteredBinary = [tree.binaries filteredArrayUsingPredicate:filterPredicate];
  return [filteredBinary lastObject];
}


#pragma mark Data manipulation
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
