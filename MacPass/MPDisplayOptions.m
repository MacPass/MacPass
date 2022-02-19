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
    self.statusItem.button.image = [bundle imageForResource:@"Lock"];

    [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown|NSEventMaskLeftMouseUp|NSEventMaskRightMouseUp|NSEventModifierFlagOption) handler:^(NSEvent *event){

      [self itemClickedEvent:event];
//      self.statusItem.button.target = self;
      return event;
      
    }];

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
//  [NSApp terminate:self];
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
  
  NSLog(@"lock db %@", _currentDoc);

  NSLog(@"attempted lock");
  }
}
- (void)itemClickedEvent:(NSEvent *)sender {
  NSLog(@"mouse event type %lu", (unsigned long)sender.type);
  NSEvent *event = sender;
  NSLog(@"mouse event type %lu", (unsigned long)event.type);
  unsigned long mouseEventType = event.type;

  
  if (([event modifierFlags] & NSEventModifierFlagOption) && mouseEventType == 1) {
    NSLog(@"option click detected");
    [[NSApplication sharedApplication] terminate:self];
  }
  else if (mouseEventType == 4) {
    NSLog(@"right click detected");
    [self performSelector:@selector(showStatusMenu:) withObject:self];
    [self performSelector:@selector(menuDidClose:) withObject:self afterDelay:0.01];
  }
  else if (((([event modifierFlags] & NSEventModifierFlagControl)) && mouseEventType == 1)){
    NSLog(@"control click detected");

    [self performSelector:@selector(showStatusMenu:) withObject:self];
//    [self.statusItem.button didCloseMenu:self.statusItem.menu withEvent: nil];
//    [self.statusItem popUpStatusItemMenu:menu];
    [self performSelector:@selector(menuDidClose:) withObject:self afterDelay:0.01];
//    self.statusItem.menu = nil;
    [self.statusItem.button highlight:NO];


    
  }
  else if (mouseEventType == 1) {
    NSLog(@"regularclick detected");
    [self performSelector:@selector(activateMacPass)];
  }
}

- (void) showStatusMenu: (id) sender {

    NSMenu *menu = [[NSMenu alloc] init];

    NSMenuItem *showHide = [[NSMenuItem alloc]initWithTitle:@"Show/Hide" action:@selector(activateMacPass) keyEquivalent:@""];
    NSMenuItem *lockDB = [[NSMenuItem alloc]initWithTitle:@"Lock" action:@selector(lockOpenDatabase:) keyEquivalent:@""];
    NSMenuItem *lockAllDB = [[NSMenuItem alloc]initWithTitle:@"Lock All" action:@selector(lockAllDatabases:) keyEquivalent:@""];
    NSMenuItem *quitMacPass = [[NSMenuItem alloc] initWithTitle:@"Quit MacPass" action:@selector(quitMacPass:) keyEquivalent:@""];
    
    

    NSMenuItem *openDB = [[NSMenuItem alloc] initWithTitle:@"Open" action:@selector(openSelectFile) keyEquivalent:@""];
    openDB.target = self;

    [showHide setTarget:self];
    [lockDB setTarget:self];
    [lockAllDB setTarget:self];
    [quitMacPass setTarget:self];

    [menu addItem:showHide];
    [menu addItem:lockDB];
    [menu addItem:lockAllDB];
    [menu addItem:quitMacPass];
    self.statusItem.menu = menu;
    [self.statusItem.button performClick:nil];
    
}

- (void) menuWillOpen: (NSMenu *) menu
{
    self.statusMenuOpen = YES;
}

- (void) menuDidClose:(NSMenu *) menu
{
    
    // Tear down the menu cause otherwise the left click won't work
    self.statusItem.menu = nil;
    [self.statusItem.button setAction:@selector(itemClickedEvent:)];
    self.statusMenuOpen = NO;
}


@end
