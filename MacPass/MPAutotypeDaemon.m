//
//  MPAutotypeDaemon.m
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDaemon.h"
#import "MPDocument.h"

#import "MPDocument+Autotype.h"
#import "MPAutotypeCommand.h"
#import "MPAutotypeContext.h"
#import "MPAutotypePaste.h"

#import "MPPasteBoardController.h"
#import "MPSettingsHelper.h"


#import "KPKEntry.h"

#import "DDHotKeyCenter.h"
#import <Carbon/Carbon.h>

NSString *const kMPWindowTitleKey = @"windowTitle";
NSString *const kMPApplciationNameKey = @"applicationName";

@interface MPAutotypeDaemon ()

@property (nonatomic, assign) BOOL enabled;
@property (copy) NSString *lastFrontMostApplication;

@end

@implementation MPAutotypeDaemon

- (id)init {
  self = [super init];
  if (self) {
    _enabled = NO;
    [self bind:@"enabled"
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableGlobalAutotype]
       options:nil];
  }
  return self;
}

- (void)dealloc {
  [self unbind:@"enabled"];
}

#pragma mark Properties
- (void)setEnabled:(BOOL)enabled {
  if(_enabled != enabled) {
    _enabled = enabled;
    self.enabled ? [self _registerHotKey] : [self _unregisterHotKey];
  }
}

- (void)executeAutotypeWithSelectedMatch:(id)sender {
  NSMenuItem *item = [self.matchSelectionButton selectedItem];
  MPAutotypeContext *context = [item representedObject];
  [self.matchSelectionWindow orderOut:self];
  [self _performAutotypeForContext:context];
}

- (void)cancelAutotypeSelection:(id)sender {
  [self.matchSelectionWindow orderOut:sender];
  if(self.lastFrontMostApplication) {
    [MPAutotypeDaemon _orderApplicationToFront:self.lastFrontMostApplication];
  }
}

- (void)_didPressHotKey {

  /* Reset the applciation on every keypress */
  self.lastFrontMostApplication = nil;
  
  NSArray *documents = [NSApp orderedDocuments];
  MPDocument *currentDocument = nil;
  for(MPDocument *openDocument in documents) {
    if(NO == openDocument.encrypted) {
      currentDocument = openDocument;
      break;
    }
  }
  if(!currentDocument) {
    return; // No need to search in closed documents
  }
  /*
   Determine the window title of  the current front most application
   Start searching the db for the best fit (based on title, then on window associations
   */
  NSDictionary *frontApplicationInfoDict = [self _frontMostApplicationInfoDict];
  NSString *windowTitle = frontApplicationInfoDict[kMPWindowTitleKey];
  self.lastFrontMostApplication = frontApplicationInfoDict[kMPApplciationNameKey];  
  /*
   Query the document to generate a autotype command list for the window title
   We do not care where this came form, just get the autotype commands
   */
  NSArray *autotypeCandidates = [currentDocument autotypContextsForWindowTitle:windowTitle];
  NSInteger candiates = [autotypeCandidates count];
  if(candiates == 0) {
    return; // No Entries found.
  }
  if(candiates > 1) {
    [self _presentSelectionWindow:autotypeCandidates];
    return; // Nothing to do, we get called back by the window
  }
  [self _performAutotypeForContext:autotypeCandidates[0]];
}

- (void)_performAutotypeForContext:(MPAutotypeContext *)context {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *commands = [MPAutotypeCommand commandsForContext:context];
    [MPAutotypeDaemon _orderApplicationToFront:self.lastFrontMostApplication];
    BOOL lastCommandWasPaste = NO;
    for(MPAutotypeCommand *command in commands) {
      if(lastCommandWasPaste) {
        NSLog(@"Sleeping for pasting!");
        usleep(1000*1000);
      }
      [command execute];
      lastCommandWasPaste = [command isKindOfClass:[MPAutotypePaste class]];
    }
  });
}

- (void)_registerHotKey {
  [[DDHotKeyCenter sharedHotKeyCenter] registerHotKeyWithKeyCode:kVK_ANSI_M
                                                   modifierFlags:(NSCommandKeyMask | NSAlternateKeyMask )
                                                          target:self
                                                          action:@selector(_didPressHotKey)
                                                          object:nil];
}

- (void)_unregisterHotKey {
  [[DDHotKeyCenter sharedHotKeyCenter] unregisterHotKeysWithTarget:self action:@selector(_didPressHotKey)];
}

- (NSDictionary *)_frontMostApplicationInfoDict {
  NSRunningApplication *frontApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
  NSString *name = frontApplication.localizedName;
  
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowTitle = windowDict[(NSString *)kCGWindowName];
    if([windowTitle length] <= 0) {
      continue;
    }
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(frontApplication.processIdentifier)]) {
      return @{
               kMPWindowTitleKey:windowDict[(NSString *)kCGWindowName],
               kMPApplciationNameKey : name
               };
    }
  }
  return nil;
}

- (void)_presentSelectionWindow:(NSArray *)candidates {
  if(!self.matchSelectionWindow) {
    [[NSBundle mainBundle] loadNibNamed:@"AutotypeCandidateSelectionWindow" owner:self topLevelObjects:nil];
    [self.matchSelectionWindow setLevel:NSFloatingWindowLevel];
  }
  NSMenu *associationMenu = [[NSMenu alloc] init];
  [associationMenu addItemWithTitle:NSLocalizedString(@"SELECT_AUTOTYPE_CANDIDATE", "") action:NULL keyEquivalent:@""];
  [associationMenu addItem:[NSMenuItem separatorItem]];
  [associationMenu setAutoenablesItems:NO];
  for(MPAutotypeContext *context in candidates) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:context.entry.title action:0 keyEquivalent:@""];
    [item setRepresentedObject:context];
    [associationMenu addItem:item];
    NSArray *attributes = @[ context.entry.username, context.command ];
    for(NSString *value in attributes) {
      NSMenuItem *valueItem  = [[NSMenuItem alloc] initWithTitle:value action:NULL keyEquivalent:@""];
      [valueItem setIndentationLevel:1];
      [valueItem setEnabled:NO];
      [associationMenu addItem:valueItem];
    }
  }
  [self.matchSelectionButton setMenu:associationMenu];
  [NSApp activateIgnoringOtherApps:YES];
  [self.matchSelectionWindow makeKeyAndOrderFront:self];
  /* Setup Items in Popup */
}

+ (void)_orderApplicationToFront:(NSString *)applicationName {
  //NSLog(@"Moving %@ to the front.", applicationName);
  NSString *appleScript = [[NSString alloc] initWithFormat:@"activate application \"%@\"", applicationName];
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:appleScript];
  NSDictionary *error;
  NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&error];
  if(!descriptor) {
    NSLog(@"Error trying to execure %@: %@", script, error);
  }
}


@end
