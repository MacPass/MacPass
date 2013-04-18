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
#import "MPPasswordCreatorViewController.h"
#import "MPActionHelper.h"
#import "MPSettingsHelper.h"
#import "NSString+MPPasswordCreation.h"

@interface MPAppDelegate ()

@property (retain, nonatomic) MPSettingsController *settingsController;
@property (retain, nonatomic) MPMainWindowController *mainWindowController;
@property (retain, nonatomic) MPPasswordCreatorViewController *passwordCreatorController;

- (IBAction)showPreferences:(id)sender;

@end

@implementation MPAppDelegate

+ (void)initialize {
  [MPSettingsHelper setupDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.mainWindowController = [[[MPMainWindowController alloc] init] autorelease];
  [self.mainWindowController showWindow:[self.mainWindowController window]];
  
}

- (void)dealloc {
  [_settingsController release];
  [_mainWindowController release];
  [_passwordCreatorController release];
  [super dealloc];
}

- (NSString *)applicationName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

#pragma mark Menu Actions

- (void)showMainWindow:(id)sender {
  [self.mainWindowController showMainWindow:sender];
}

- (void)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[[MPSettingsController alloc] init] autorelease];
  }
  [self.settingsController showSettings];
}

- (void)showPasswordCreator:(id)sender {
  if(!self.passwordCreatorWindow) {
    [[NSBundle mainBundle] loadNibNamed:@"PasswordCreatorWindow"owner:self topLevelObjects:nil];
  }
  if(!self.passwordCreatorController) {
    self.passwordCreatorController = [[MPPasswordCreatorViewController alloc] init];
  }
  [self.passwordCreatorWindow setContentView:[self.passwordCreatorController view]];
  [self.passwordCreatorWindow makeKeyAndOrderFront:self.passwordCreatorWindow];
}

- (NSArray *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags {
  BOOL insertCreate = (0 != (flags & MPContextMenuCreate));
  BOOL insertDelete = (0 != (flags & MPContextMenuDelete));
  BOOL insertCopy = (0 != (flags & MPContextMenuCopy));
  
  NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
  if(insertCreate) {
    
    NSMenuItem *newGroup = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_GROUP", @"")
                                                      action:[MPActionHelper actionOfType:MPActionAddGroup]
                                               keyEquivalent:@"G"];
    NSMenuItem *newEntry = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_ENTRY", @"")
                                                      action:[MPActionHelper actionOfType:MPActionAddEntry]
                                               keyEquivalent:@"E"];
    
    [items addObjectsFromArray:@[ newGroup, newEntry ]];
    [newEntry release];
    [newGroup release];
  }
  if(insertDelete) {
    if([items count] > 0) {
      [items addObject:[NSMenuItem separatorItem]];
    }
    NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", @"")
                                                    action:[MPActionHelper actionOfType:MPActionDelete]
                                             keyEquivalent:@""];
    [items addObject:delete];
    [delete release];
  }
  if(insertCopy) {
    if([items count] > 0) {
      [items addObject:[NSMenuItem separatorItem]];
    }
    NSMenuItem *copyUsername = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_USERNAME", @"")
                                                          action:[MPActionHelper actionOfType:MPActionCopyUsername]
                                                   keyEquivalent:@"C"];
    NSMenuItem *copyPassword = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_PASSWORD", @"")
                                                          action:[MPActionHelper actionOfType:MPActionCopyPassword]
                                                   keyEquivalent:@"c"];
    NSMenu *urlMenu = [[NSMenu alloc] init];
    NSMenuItem *urlItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"URL", @"")
                                                     action:0
                                              keyEquivalent:@""];
    [urlItem setSubmenu:urlMenu];
    [urlMenu release];
    
    NSMenuItem *copyURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_URL", @"")
                                                     action:[MPActionHelper actionOfType:MPActionCopyURL]
                                              keyEquivalent:@"u"];
    NSMenuItem *openURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPEN_URL", @"")
                                                     action:[MPActionHelper actionOfType:MPActionOpenURL]
                                              keyEquivalent:@"U"];
    [urlMenu addItem:copyURL];
    [urlMenu addItem:openURL];
    [openURL release];
    [copyURL release];
    
    [items addObjectsFromArray:@[ copyUsername, copyPassword, urlItem]];
    [urlItem release];
    [copyPassword release];
    [copyUsername release];
  }
  return items;
}



@end
