//
//  MPWorkflowSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 30.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPWorkflowSettingsController.h"

#import "MPSettingsHelper.h"

NSString *const kMPChromeBundleId = @"com.google.chrome";
NSString *const kMPSafariBundleId = @"com.apple.safari";
NSString *const kMPFirefoxBundleId = @"org.mozilla.firefox";

@interface MPWorkflowSettingsController ()

@end

@implementation MPWorkflowSettingsController

#pragma mark LifeCycle
- (id)init {
  self = [self initWithNibName:@"WorkflowSettings" bundle:nil];
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)didLoadView {
  NSMenu *browserMenu = [[NSMenu alloc] init];
  [browserMenu addItemWithTitle:NSLocalizedString(@"DEFAULT_BROWSER", "Default Browser") action:NULL keyEquivalent:@""];
  [browserMenu addItem:[NSMenuItem separatorItem]];
  
  NSArray *browser  = @[kMPChromeBundleId, kMPSafariBundleId, kMPFirefoxBundleId];
  for(NSString *bundle in browser) {
  
  }
  
  if([[browserMenu itemArray] count] > 2) {
    [browserMenu addItem:[NSMenuItem separatorItem]];
  }
  [browserMenu addItemWithTitle:NSLocalizedString(@"OTHER_BROWSER", "Selecte Browser") action:NULL keyEquivalent:@""];
  
  [self.browserPopup setMenu:browserMenu];
}

#pragma mark MPSettingsTab Protocol
- (NSString *)identifier {
  return @"WorkflowSettings";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)label {
  return NSLocalizedString(@"WORKFLOW", "");
}

#pragma mark Actions
- (IBAction)selectBrowser:(id)sender {
  NSString *browserBundleId = [sender representedObject];
  NSLog(@"New default Browser: %@", browserBundleId);
  [[NSUserDefaults standardUserDefaults] setObject:browserBundleId forKey:kMPSettingsKeyBrowserBundleId];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Helper
- (NSArray *)_availableBrowser {
  NSArray *browser  = @[kMPChromeBundleId, kMPSafariBundleId, kMPFirefoxBundleId];
  for(NSString *bundle in browser) {
    
  }
  return nil;
}

@end
