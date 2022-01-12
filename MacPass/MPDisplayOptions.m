//
//  MPDisplayOptions.m
//  MacPass
//
//  Created by George snow on 1/11/22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cocoa/Cocoa.h"
#import "MPDisplayOptions.h"
#import "MPDocument.h"

#import "MPAppDelegate.h"

@interface MPDisplayOption ()
@property (strong) NSStatusItem *statusItem;

@property (weak) MPDocument *currentDoc;
@property (readonly) BOOL queryDocumentOpen;

@property (weak) MPAppDelegate *mpDelegate;

@end

@implementation MPDisplayOption

- (instancetype)init {
  self = [super init];
  if(self)
  {
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    

    
    
    // TODO: Use scalable graphic (e.g. PDF)
    self.statusItem.button.image = [bundle imageForResource:@"Lock"];
    [self.statusItem.button sendActionOn:(NSEventMaskLeftMouseDown|NSEventMaskRightMouseDown|NSEventMaskLeftMouseUp|NSEventMaskRightMouseUp)];
    self.statusItem.button.action = @selector(itemClicked:);
    self.statusItem.button.target = self;
    [self statusItem];
    
  }
  return self;
}

- (void)activateMacPass {
  bool mpActive = [NSApp isActive];
  if(mpActive) {
    [NSApplication.sharedApplication hide:nil];
  }
  else {
    [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
    
  }
  
}

-(void)openSelectFile {
  
  [(MPAppDelegate *)NSApp.delegate showWelcomeWindow];
  
  
}

- (void)quitMacPass:(id)sender {
  [[NSApplication sharedApplication] terminate:self];
  return;
}

-(void)lockOpenDatabase:(id)sender{
  MPDocument *currentDocument = [NSDocumentController sharedDocumentController].currentDocument;
  
  if (currentDocument.encrypted){
    NSLog(@"Current database locked: %@", currentDocument.displayName);
    
  }
  else {
    [currentDocument lockDatabase:nil];
    NSLog(@"attempted lock on: %@", currentDocument.displayName);
  }
}

- (BOOL)queryDocumentOpen {
  return self.currentDoc && !self.currentDoc.encrypted;
}

-(void)lockAllDatabases:(id)sender{
  NSArray *documents = [NSDocumentController sharedDocumentController].documents;
  MPDocument __weak *lastDocument;
  for(MPDocument *document in documents) {
    if(document.encrypted) {
      NSLog(@"Database is Locked: %@", document.displayName);
      
      continue;
    }
    lastDocument = document;
  [lastDocument lockDatabase:nil];
  
//  [_currentDoc lockDatabase:nil];
  NSLog(@"lock db %@", _currentDoc);

  NSLog(@"attempted lock");
  }
}

- (void)itemClicked:(id)sender {
  //_statusItem.menu = nil;
  NSEvent *event = [NSApp currentEvent];
  NSLog(@"mouse event type %lu", (unsigned long)event.type);
  unsigned long mouseEventType = event.type;
  
  
  if (([event modifierFlags] & NSEventModifierFlagOption) && mouseEventType == 2) {
    NSLog(@"option click detected");
    [self performSelector:@selector(quitMacPass:)];
  }
  else if (((([event modifierFlags] & NSEventModifierFlagControl)) && mouseEventType == 2) | (mouseEventType == 3)){
    NSLog(@"control click detected");
//    self.statusItem.menu = [self updateStatusBarMenu];
    NSMenu *menu = [[NSMenu alloc] init];
//    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidClose:) name:NSMenuDidEndTrackingNotification object:self.statusItem.menu];
//
    NSMenuItem *showHide = [[NSMenuItem alloc]initWithTitle:@"Show/Hide" action:@selector(activateMacPass) keyEquivalent:@""];
    NSMenuItem *lockDB = [[NSMenuItem alloc]initWithTitle:@"Lock" action:@selector(lockOpenDatabase:) keyEquivalent:@""];
    NSMenuItem *lockAllDB = [[NSMenuItem alloc]initWithTitle:@"Lock All" action:@selector(lockAllDatabases:) keyEquivalent:@""];
    NSMenuItem *quitMacPass = [[NSMenuItem alloc] initWithTitle:@"Quit MacPass" action:@selector(quitMacPass:) keyEquivalent:@""];
    
    
    //new menu items

//    Open menu causes strange behavior
    NSMenuItem *openDB = [[NSMenuItem alloc] initWithTitle:@"Open" action:@selector(openSelectFile) keyEquivalent:@""];
    openDB.target = self;
//    [menu addItem:openDB];
//
//    NSMenuItem *prefMacPass = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(showPluginPrefs) keyEquivalent:@""];
//    prefMacPass.target = self;
//    [menu addItem:prefMacPass];
    
    [showHide setTarget:self];
    [lockDB setTarget:self];
    [lockAllDB setTarget:self];
    [quitMacPass setTarget:self];

//    [menu addItem:showHide];
    [menu addItem:lockDB];
    [menu addItem:lockAllDB];
    [menu addItem:quitMacPass];
    self.statusItem.menu = menu;
    

//    set the delegate to allow for right click and replace popUpStatusItemMenu??
//    [self.statusItem.menu setDelegate:self];
    
    
    //Depecrated  in 10.14 - used for right click to display menu
    //replaced when popover version is completed
    [self.statusItem popUpStatusItemMenu:menu];
    self.statusItem.menu = nil;
    [self.statusItem.button highlight:NO];

    //    self.statusItem.button.menu = menu;
    
  }
  else if (mouseEventType == 2) {
    NSLog(@"regularclick detected");
    [self performSelector:@selector(activateMacPass)];
  }
}
-(void)removeStatusItem:(id)sender {
  [NSStatusBar.systemStatusBar removeStatusItem:self.statusItem];
  self.statusItem = nil;
  
}

@end
