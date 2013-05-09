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

@interface MPDocument ()

@property (retain) KdbTree *tree;
@property (retain) NSURL *file;
@property (nonatomic, readonly) KdbPassword *passwordHash;
@property (assign) MPDatabaseVersion version;

@end


@implementation MPDocument

- (id)init
{
  return [self initWithVersion:MPDatabaseVersion4];
}

- (id)initWithVersion:(MPDatabaseVersion)version {
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

- (void) makeWindowControllers {
  
  MPDocumentWindowController *windowController = [[MPDocumentWindowController alloc] init];
  [self addWindowController:windowController];  
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  // Add any code here that needs to be executed once the windowController has loaded the document's window.
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
  return YES;
  // tell The window controller to display decrypt view
//  - (void)openDocument:(id)sender {
//    
//    if(!self.passwordInputController) {
//      self.passwordInputController = [[[MPPasswordInputController alloc] init] autorelease];
//    }
//    
//    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
//    [openPanel setCanChooseDirectories:NO];
//    [openPanel setCanChooseFiles:YES];
//    [openPanel setCanCreateDirectories:NO];
//    [openPanel setAllowsMultipleSelection:NO];
//    [openPanel setAllowedFileTypes:@[ @"kdbx", @"kdb"]];
//    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
//      if(result == NSFileHandlingPanelOKButton) {
//        NSURL *file = [[openPanel URLs] lastObject];
//        self.passwordInputController.fileURL = file;
//        [self _setContentViewController:self.passwordInputController];
//      }
//    }];
//  }
//  
  
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
}

- (KdbPassword *)passwordHash {
  // TODO: Use defaults to determine Encoding?
  return [[[KdbPassword alloc] initWithPassword:self.password passwordEncoding:NSUTF8StringEncoding keyFile:[self.key path]] autorelease];
}

+ (BOOL)autosavesInPlace
{
  return NO;
}

@end
