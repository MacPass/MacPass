//
//  MPAppDelegate.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPAppDelegate.h"

#import "MPMainWindowController.h"
#import "MPSettingsController.h"
#import "MPDatabaseController.h"

@interface MPAppDelegate ()

@property (retain) MPSettingsController *settingsController;
@property (retain) MPMainWindowController *mainWindowController;
@property (assign) IBOutlet NSMenuItem *toggleOutlineViewMenuItem;
@property (assign) IBOutlet NSMenuItem *toggleInspectorViewMenuItem;

- (void)_setupMenues;

- (IBAction)showPreferences:(id)sender;
@end

@implementation MPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.mainWindowController = [[[MPMainWindowController alloc] init] autorelease];
  [self.mainWindowController showWindow:[self.mainWindowController window]];
  [self _setupMenues];
  
}

- (void)dealloc {
  [_settingsController release];
  [_mainWindowController release];
  [super dealloc];
}

- (NSString *)applicationName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

#pragma mark Setup

- (void)_setupMenues {
  [self.toggleInspectorViewMenuItem setAction:@selector(toggleInspector:)];
  [self.toggleOutlineViewMenuItem setAction:@selector(toggleOutlineView:)];
}

#pragma mark Menu Actions

- (void)showMainWindow:(id)sender {
  [self.mainWindowController showMainWindow:sender];
}

- (void)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[[MPSettingsController alloc] init] autorelease];
  }
  [self.settingsController showWindow:_settingsController.window];
}

- (NSArray *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags {
  BOOL insertCreate = (0 != (flags & MPContextMenuCreate));
  BOOL insertDelete = (0 != (flags & MPContextMenuDelete));
  BOOL insertCopy = (0 != (flags & MPContextMenuCopy));
  
  NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
  if(insertCreate) {
    NSMenuItem *newGroup = [[NSMenuItem alloc] initWithTitle:@"New Group" action:@selector(createGroup:) keyEquivalent:@"G"];
    NSMenuItem *newEntry = [[NSMenuItem alloc] initWithTitle:@"New Entry" action:@selector(createEntry:) keyEquivalent:@"E"];
    [items addObjectsFromArray:@[ newGroup, newEntry ]];
    [newEntry release];
    [newGroup release];
  }
  if(insertDelete) {
    if([items count] > 0) {
      [items addObject:[NSMenuItem separatorItem]];
    }
    NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteEntry:) keyEquivalent:@""];
    [items addObject:delete];
    [delete release];
  }
  if(insertCopy) {
    if([items count] > 0) {
      [items addObject:[NSMenuItem separatorItem]];
    }
    NSMenuItem *copyUsername = [[NSMenuItem alloc] initWithTitle:@"Copy Username" action:@selector(copyUsername:) keyEquivalent:@"C"];
    NSMenuItem *copyPassword = [[NSMenuItem alloc] initWithTitle:@"Copy Password" action:@selector(copyPassword:) keyEquivalent:@"c"];
    NSMenuItem *openURL = [[NSMenuItem alloc] initWithTitle:@"Open URL" action:@selector(openURL:) keyEquivalent:@"U"];
    [items addObjectsFromArray:@[ copyUsername, copyPassword, openURL]];
    [copyPassword release];
    [copyUsername release];
    [openURL release];
  }
  return items;
}

@end
