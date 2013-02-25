//
//  MPGeneralSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPGeneralSettingsController.h"

NSString *const MPGeneralSetingsIdentifier = @"GeneralSettingsTab";

@interface MPGeneralSettingsController ()
@property (assign) IBOutlet NSPopUpButton *encodingPopup;
- (void)didLoadView;
@end

@implementation MPGeneralSettingsController

+ (NSString *)identifier {
  return MPGeneralSetingsIdentifier;
}

+ (NSImage *)image {
  return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (id)init {
  return [self initWithNibName:@"GeneralSettings" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)didLoadView {
  // setup connections
  NSMenu *encodingMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
  NSMenuItem *item;
  
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"UTF8 Encoding" action:NULL keyEquivalent:@""];
  [item setRepresentedObject:[NSNumber numberWithInt:NSUTF8StringEncoding]];
  [encodingMenu addItem:item];
  [item release];

  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"ASCII Encoding" action:NULL keyEquivalent:@""];
  [item setRepresentedObject:[NSNumber numberWithInt:NSASCIIStringEncoding]];
  [encodingMenu addItem:item];
  [item release];

  [_encodingPopup setMenu:encodingMenu];
  [encodingMenu release];

  
}

@end
