//
//  MPDocument.m
//  MacPass
//
//  Created by Michael Starke on 08.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"
#import "MPDocumentWindowController.h"

#import "MPDatabaseVersion.h"
#import "MPRootAdapter.h"
#import "MPIconHelper.h"
#import "MPActionHelper.h"

#import "KdbLib.h"
#import "Kdb3Node.h"
#import "Kdb4Node.h"
#import "KdbPassword.h"
#import "KdbGroup+Undo.h"
#import "KdbGroup+KVOAdditions.h"
#import "Kdb4Entry+KVOAdditions.h"
#import "KdbGroup+MPTreeTools.h"
#import "KdbGroup+MPAdditions.h"
#import "KdbEntry+Undo.h"
#import "Kdb3Tree+NewTree.h"
#import "Kdb4Tree+NewTree.h"

NSString *const MPDocumentDidAddGroupNotification     = @"com.hicknhack.macpass.MPDocumentDidAddGroupNotification";
NSString *const MPDocumentWillDelteGroupNotification  = @"com.hicknhack.macpass.MPDocumentDidDelteGroupNotification";
NSString *const MPDocumentDidAddEntryNotification     = @"com.hicknhack.macpass.MPDocumentDidAddEntryNotification";
NSString *const MPDocumentWillDeleteEntryNotification = @"com.hicknhack.macpass.MPDocumentDidDeleteEntryNotification";
NSString *const MPDocumentDidRevertNotifiation        = @"com.hicknhack.macpass.MPDocumentDidRevertNotifiation";

NSString *const MPDocumentEntryKey                    = @"MPDocumentEntryKey";
NSString *const MPDocumentGroupKey                    = @"MPDocumentGroupKey";


@interface MPDocument () {
@private
  BOOL _didLockFile;
}


@property (strong, nonatomic) KdbTree *tree;
@property (weak, nonatomic) KdbGroup *root;
@property (weak, nonatomic, readonly) KdbPassword *passwordHash;
@property (assign) MPDatabaseVersion version;

@property (assign, nonatomic) BOOL secured;
@property (assign) BOOL decrypted;
@property (assign) BOOL readOnly;

@property (strong) NSURL *lockFileURL;

@property (readonly) BOOL useTrash;
@property (weak, readonly) KdbGroup *trash;

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
    _didLockFile = NO;
    _decrypted = YES;
    _secured = NO;
    _locked = NO;
    _readOnly = NO;
    _rootAdapter = [[MPRootAdapter alloc] init];
    _version = version;
    switch(_version) {
      case MPDatabaseVersion3:
        self.tree = [Kdb3Tree templateTree];
        break;
      case MPDatabaseVersion4:
        self.tree = [Kdb4Tree templateTree];
        break;
      default:
        self = nil;
        return nil;
    }
  }
  return self;
}

- (void)dealloc {
  [self _cleanupLock];
}

- (void)makeWindowControllers {
  MPDocumentWindowController *windowController = [[MPDocumentWindowController alloc] init];
  [self addWindowController:windowController];
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
  self.lockFileURL = [url URLByAppendingPathExtension:@"lock"];
  if([[NSFileManager defaultManager] fileExistsAtPath:[_lockFileURL path]]) {
    self.readOnly = YES;
  }
  else {
    [[NSFileManager defaultManager] createFileAtPath:[_lockFileURL path] contents:nil attributes:nil];
    _didLockFile = YES;
    self.readOnly = NO;
  }
  self.decrypted = NO;
  return YES;
}

- (BOOL)revertToContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
  self.tree = nil;
  if([self readFromURL:absoluteURL ofType:typeName error:outError]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidRevertNotifiation object:self];
    return YES;
  }
  return NO;
}

- (BOOL)isEntireFileLoaded {
  return _decrypted;
}

- (void)close {
  [self _cleanupLock];
  [super close];
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
  self.decrypted = YES;
  return YES;
}

- (void)setPassword:(NSString *)password {
  if(![_password isEqualToString:password]) {
    _password = password;
    _secured |= ([_password length] > 0);
  }
}

- (void)setKey:(NSURL *)key {
  if(![[_key absoluteString] isEqualToString:[key absoluteString]]) {
    _key = key;
    _secured |= (_key != nil);
  }
}

- (KdbPassword *)passwordHash {
  
  return [[KdbPassword alloc] initWithPassword:self.password passwordEncoding:NSUTF8StringEncoding keyFileURL:self.key];
}

+ (BOOL)autosavesInPlace
{
  return NO;
}

#pragma mark Data Accesors
- (void)setTree:(KdbTree *)tree {
  if(_tree != tree) {
    _tree = tree;
    self.rootAdapter.tree = _tree;
  }
}

- (KdbGroup *)root {
  return self.tree.root;
}

- (KdbEntry *)findEntry:(UUID *)uuid {
  return [self.root entryForUUID:uuid];
}

- (KdbGroup *)findGroup:(UUID *)uuid {
  return [self.root groupForUUID:uuid];
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

- (Kdb3Tree *)treeV3 {
  switch (_version) {
    case MPDatabaseVersion3:
      NSAssert([self.tree isKindOfClass:[Kdb3Tree class]], @"Tree has to be Version3");
      return (Kdb3Tree *)self.tree;
    case MPDatabaseVersion4:
      return nil;
    default:
      return nil;
  }
}

- (Kdb4Tree *)treeV4 {
  switch (_version) {
    case MPDatabaseVersion3:
      return nil;
    case MPDatabaseVersion4:
      NSAssert([self.tree isKindOfClass:[Kdb4Tree class]], @"Tree has to be Version4");
      return (Kdb4Tree *)self.tree;
    default:
      return nil;
  }
}

- (BOOL)useTrash {
  if(self.treeV4) {
    return self.treeV4.recycleBinEnabled;
  }
  return NO;
}

- (KdbGroup *)trash {
  static KdbGroup *_trash = nil;
  if(self.useTrash) {
    BOOL trashValid = [((Kdb4Group *)_trash).uuid isEqual:self.treeV4.recycleBinUuid];
    if(!trashValid) {
      _trash = [self findGroup:self.treeV4.recycleBinUuid];
    }
    return _trash;
  }
  return nil;
}

- (void)useGroupAsTrash:(KdbGroup *)group {
  if(self.useTrash) {
    Kdb4Group *groupv4 = (Kdb4Group *)group;
    if(![self.treeV4.recycleBinUuid isEqual:groupv4.uuid]) {
      self.treeV4.recycleBinUuid = groupv4.uuid;
    }
  }
}

#pragma mark Data manipulation
- (KdbEntry *)createEntry:(KdbGroup *)parent {
  if(!parent) {
    return nil; // No parent
  }
  KdbEntry *newEntry = [self.tree createEntry:parent];
  newEntry.title = NSLocalizedString(@"DEFAULT_ENTRY_TITLE", @"Title for a newly created entry");
  if(self.treeV4 && ([self.treeV4.defaultUserName length] > 0)) {
    newEntry.title = self.treeV4.defaultUserName;
  }
  [self group:parent addEntry:newEntry atIndex:[parent.entries count]];
  NSDictionary *userInfo = @{ MPDocumentEntryKey : newEntry };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidAddEntryNotification object:self userInfo:userInfo];
  return newEntry;
}

- (KdbGroup *)createGroup:(KdbGroup *)parent {
  if(!parent) {
    return nil; // no parent!
  }
  KdbGroup *newGroup = [self.tree createGroup:parent];
  newGroup.name = NSLocalizedString(@"DEFAULT_GROUP_NAME", @"Title for a newly created group");
  [self group:parent addGroup:newGroup atIndex:[parent.groups count]];
  NSDictionary *userInfo = @{ MPDocumentGroupKey : newGroup };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidAddGroupNotification object:self userInfo:userInfo];
  return newGroup;
}

- (StringField *)createStringField:(KdbEntry *)entry {
  // TODO: Localize!
  if(![entry isKindOfClass:[Kdb4Entry class]]) {
    return nil;
  }
  Kdb4Entry *entryV4 = (Kdb4Entry *)entry;
  NSString *title = NSLocalizedString(@"DEFAULT_CUSTOM_FIELD_TITLE", @"Default Titel for new Custom-Fields");
  NSString *value = NSLocalizedString(@"DEFAULT_CUSTOM_FIELD_VALUE", @"Default Value for new Custom-Fields");
  StringField *newStringField = [StringField stringFieldWithKey:title andValue:value];
  [self entry:entryV4 addStringField:newStringField atIndex:[entryV4.stringFields count]];
  return newStringField;
}


- (void)moveGroup:(KdbGroup *)group toGroup:(KdbGroup *)target index:(NSInteger)index {
  NSInteger oldIndex = [group.parent.groups indexOfObject:group];
  if(group.parent == target && oldIndex == index) {
    return; // No changes
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveGroup:group toGroup:group.parent index:oldIndex];
  if(self.trash == target) {
    [[self undoManager] setActionName:@"UNDO_DELETE_GROUP"];
  }
  else {
    [[self undoManager] setActionName:@"MOVE_GROUP"];
  }
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
  if(self.trash == target || self.trash == entry.parent) {
    [[self undoManager] setActionName:@"UNDO_DELETE_ENTRY"];
  }
  else {
    [[self undoManager] setActionName:@"MOVE_ENTRY"];
  }
  [entry.parent removeObjectFromEntriesAtIndex:oldIndex];
  if(index < 0 || index > [target.groups count] ) {
    index = [target.groups count];
  }
  [target insertObject:entry inEntriesAtIndex:index];
}

- (void)group:(KdbGroup *)group addEntry:(KdbEntry *)entry atIndex:(NSUInteger)index {
  [[[self undoManager] prepareWithInvocationTarget:self] group:group removeEntry:entry];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_ENTRY", "Undo adding of entry")];
  [group insertObject:entry inEntriesAtIndex:index];
}

- (void)group:(KdbGroup *)group addGroup:(KdbGroup *)aGroup atIndex:(NSUInteger)index {
  [[[self undoManager] prepareWithInvocationTarget:self] group:group removeGroup:aGroup];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_GROUP", @"Create Group Undo")];
  [group insertObject:aGroup inGroupsAtIndex:index];
}

- (void)group:(KdbGroup *)group removeEntry:(KdbEntry *)entry {
  NSInteger index = [group.entries indexOfObject:entry];
  if(NSNotFound == index) {
    return; // No object found;
  }
  if(self.useTrash) {
    if(!self.trash) {
      [self _createTrashGroup];
    }
    [self moveEntry:entry toGroup:self.trash index:[self.trash.entries count]];
    return;
  }
  [[[self undoManager] prepareWithInvocationTarget:self] group:group addEntry:entry atIndex:index];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_ENTRY", "Undo deleting of entry")];
  [group removeObjectFromEntriesAtIndex:index];
}

- (void)group:(KdbGroup *)group removeGroup:(KdbGroup *)aGroup {
  NSInteger index = [group.groups indexOfObject:aGroup];
  if(NSNotFound == index) {
    return; // No object found
  }
  if(self.trash == aGroup) {
    return;
    // delete Trash?
  }
  /*
   Cleaning the recyclebin is not undoable
   So we do this in a separate action
   */
  if(self.useTrash) {
    if(!self.trash) {
      [self _createTrashGroup];
    }
    [self moveGroup:aGroup toGroup:self.trash index:[self.trash.groups count]];
    return; // Done!
  }
  [[[self undoManager] prepareWithInvocationTarget:self] group:group addGroup:aGroup atIndex:index];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_GROUP", @"Delete Group Undo")];
  [group removeObjectFromGroupsAtIndex:index];
}

- (void)entry:(Kdb4Entry *)entry addStringField:(StringField *)field atIndex:(NSUInteger)index {
  [[[self undoManager] prepareWithInvocationTarget:self] entry:entry removeStringField:field];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_STRING_FIELD", @"Add Stringfield Undo")];
  [entry insertObject:field inStringFieldsAtIndex:index];
}

- (void)entry:(Kdb4Entry *)entry removeStringField:(StringField *)field {
  NSInteger index = [entry.stringFields indexOfObject:field];
  if(NSNotFound == index) {
    return; // Nothing found to be removed
  }
  [[[self undoManager] prepareWithInvocationTarget:self] entry:entry addStringField:field atIndex:index];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_STRING_FIELD", @"Delte Stringfield undo")];
  [entry removeObjectFromStringFieldsAtIndex:index];
}

#pragma mark Actions

- (void)emptyTrash:(id)sender {
  [[self undoManager] setActionIsDiscardable:YES];
  [self.trash clear];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if([menuItem action] == [MPActionHelper actionOfType:MPActionEmptyTrash]) {
    BOOL hasGroups = [self.trash.groups count] > 0;
    BOOL hasEntries = [self.trash.entries count] > 0;
    return (hasEntries || hasGroups);
  }
  return YES;
}

#pragma mark Private
- (void)_cleanupLock {
  if(_didLockFile) {
    [[NSFileManager defaultManager] removeItemAtURL:_lockFileURL error:nil];
    _didLockFile = NO;
  }
}

- (KdbGroup *)_createTrashGroup {
  /* Maybe push the stuff to the Tree? */
  if(self.version == MPDatabaseVersion3) {
    return nil;
  }
  else if(self.version == MPDatabaseVersion4) {
    KdbGroup *trash = [self.tree createGroup:self.tree.root];
    trash.name = NSLocalizedString(@"TRASH_GROUP", @"Name for the trash group");
    trash.image = MPIconTrash;
    [self.tree.root insertObject:trash inGroupsAtIndex:[self.tree.root.groups count]];
    self.treeV4.recycleBinUuid = ((Kdb4Group *)trash).uuid;
    return trash;
  }
  else {
    NSAssert(NO, @"Database with unknown version: %ld", _version);
    return nil;
  }
}

@end
