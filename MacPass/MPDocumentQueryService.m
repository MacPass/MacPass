//
//  MPDocumentQueryService.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentQueryService.h"
#import "MPDocumentWindowController.h"
#import "MPDocument.h"
#import "KPKEntry.h"
#import "NSString+MPPasswordCreation.h"
#import "NSString+Commands.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "KPHResponse.h"
#import "KPKAttribute.h"
#import "KPKTree.h"

#import "NSUUID+KeePassKit.h"

#define AES_KEY_ATTRIBUTE @"AES key: %@"

static NSUUID *_rootUuid = nil;

@interface MPDocumentQueryService ()

@property (weak) MPDocument *queryDocument;
@property (nonatomic, weak) KPKEntry *configurationEntry;
@property (readonly) BOOL queryDocumentOpen;

@end

@implementation MPDocumentQueryService

+ (MPDocumentQueryService *)sharedService {
  static id instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPDocumentQueryService alloc] init];
  });
  return instance;
}

- (id)init {
  self = [super init];
  if (self) {
    static const uuid_t uuidBytes = {
      0x34, 0x69, 0x7a, 0x40, 0x8a, 0x5b, 0x41, 0xc0,
      0x9f, 0x36, 0x89, 0x7d, 0x62, 0x3e, 0xcb, 0x31
    };
    _rootUuid = [[NSUUID alloc] initWithUUIDBytes:uuidBytes];
  }
  return self;
}

- (BOOL)queryDocumentOpen {
  [self configurationEntry];
  return self.queryDocument && !self.queryDocument.encrypted;
}

- (KPKEntry *)configurationEntry {
  /* don't return the configurationEntry if it is isn't in the root group, we will move it there first */
  if(_configurationEntry != nil && [_configurationEntry.parent.uuid isEqual:_queryDocument.root.uuid])
    return  _configurationEntry;
  
  NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
  
  MPDocument __weak *lastDocument;
  
  for(MPDocument *document in documents) {
    if(document.encrypted) {
      NSLog(@"Skipping locked Database: %@", [document displayName]);
      /* TODO: Show input window and open db with window */
      continue;
    }
    
    lastDocument = document;
    
    KPKEntry *configEntry = [document findEntry:_rootUuid];
    if(nil != configEntry) {
      /* if the configEntry is not in the root group then move it there */
      if (![configEntry.parent.uuid isEqual:document.root.uuid])
        [configEntry moveToGroup:document.root atIndex:0];
      
      self.configurationEntry = configEntry;
      self.queryDocument = document;
      return _configurationEntry;
    }
  }
  
  if (lastDocument)
    return [self _createConfigurationEntry:lastDocument];
  
  return nil;
}

- (KPKEntry *)_createConfigurationEntry:(MPDocument *)document {
  KPKEntry *configEntry = [document.tree createEntry:document.root];
  configEntry.title = @"KeePassHttp Settings";
  configEntry.uuid = _rootUuid;
  [document.root addEntry:configEntry];
  
  self.configurationEntry = [document findEntry:_rootUuid];
  self.queryDocument = document;
  
  return self.configurationEntry;
}

#pragma mark - KPHDelegate

+ (NSArray *)recursivelyFindEntriesInGroups:(NSArray *)groups forURL:(NSString *)url usingTree:(KPKTree *)tree {
  NSMutableArray *entries = @[].mutableCopy;
  
  for (KPKGroup *group in groups) {
    /* recurse through any subgroups */
    [entries addObjectsFromArray:[MPDocumentQueryService recursivelyFindEntriesInGroups:group.groups forURL:url usingTree:tree]];
    
    /* check each entry in the group */
    for (KPKEntry *entry in group.entries) {
      NSString *entryUrl = [entry.url resolveReferencesWithTree:tree];
      NSString *entryTitle = [entry.title resolveReferencesWithTree:tree];
      NSString *entryUsername = [entry.username resolveReferencesWithTree:tree];
      NSString *entryPassword = [entry.password resolveReferencesWithTree:tree];
      
      if (url == nil || [entryTitle rangeOfString:url].location != NSNotFound || [entryUrl rangeOfString:url].location != NSNotFound) {
        [entries addObject:[KPHResponseEntry entryWithUrl:entryUrl name:entryTitle login:entryUsername password:entryPassword uuid:[entry.uuid UUIDString] stringFields:nil]];
      }
    }
  }
  
  return entries;
}

- (NSArray *)server:(KPHServer *)server entriesForURL:(NSString *)url {
  if (!self.queryDocumentOpen)
    return @[];
  
  return [MPDocumentQueryService recursivelyFindEntriesInGroups:self.queryDocument.root.groups forURL:url usingTree:self.queryDocument.tree];
}

- (NSString *)server:(KPHServer *)server keyForLabel:(NSString *)label {
  if (!self.queryDocumentOpen)
    return nil;
  
  return [self.configurationEntry customAttributeForKey:[NSString stringWithFormat:AES_KEY_ATTRIBUTE, label]].value;
}

- (NSString *)server:(KPHServer *)server labelForKey:(NSString *)key {
  if (!self.queryDocumentOpen)
    return nil;
  
  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:NSLocalizedString(@"Yes", @"")];
  [alert addButtonWithTitle:NSLocalizedString(@"No", @"")];
  [alert setMessageText:@"KeePassHttp"];
  [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"A server with the key \"%@\" has requested access to your password database. Would you like to allow access?", @""), key]];
  [alert setAlertStyle:NSWarningAlertStyle];
  
  NSString __block *label = nil;
  dispatch_semaphore_t sema = dispatch_semaphore_create(0L);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSInteger ret = [alert runModal];
    if (ret == NSAlertFirstButtonReturn) {
      // TODO: get label from user input
      label = [NSString passwordWithCharactersets:MPPasswordCharactersLowerCase length:16];
      [self.configurationEntry addCustomAttribute:[[KPKAttribute alloc] initWithKey:[NSString stringWithFormat:AES_KEY_ATTRIBUTE, label] value:key]];
    }
    dispatch_semaphore_signal(sema);
  });
  
  dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  
  return label;
}

- (void)server:(KPHServer *)server setUsername:(NSString *)username andPassword:(NSString *)password forURL:(NSString *)url withUUID:(NSString *)uuid {
  if (!self.queryDocumentOpen)
    return;
  
  KPKEntry *entry = nil;
  if (uuid)
    entry = [self.queryDocument findEntry:[[NSUUID alloc] initWithUUIDString:uuid]];
  
  BOOL shouldAddEntry = !entry;
  
  if (!entry)
    entry = [self.queryDocument.tree createEntry:self.queryDocument.root]; // TODO: store this somewhere better
  
  entry.title = url;
  entry.username = username;
  entry.password = password;
  entry.url = url;
  
  if (shouldAddEntry)
    [self.queryDocument.root addEntry:entry];
}

- (NSArray *)allEntriesForServer:(KPHServer *)server {
  if (!self.queryDocumentOpen)
    return @[];
  
  return [MPDocumentQueryService recursivelyFindEntriesInGroups:self.queryDocument.root.groups forURL:nil usingTree:self.queryDocument.tree];
}

- (NSString *)generatePasswordForServer:(KPHServer *)server {
  return [NSString passwordWithDefaultSettings];
}

- (NSString *)clientHashForServer:(KPHServer *)server {
  if (!self.queryDocumentOpen)
    return nil;
  
  return [NSString stringWithFormat:@"%@%@", [self.queryDocument.root.uuid UUIDString], [self.queryDocument.trash.uuid UUIDString]];
}

@end
