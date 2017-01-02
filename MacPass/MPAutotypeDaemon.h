//
//  MPAutotypeDaemon.h
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDHotKey;
@class KPKEntry;

/**
 *  The autotype daemon is responsible for registering the global hotkey and to perform any autotype actions
 */
@interface MPAutotypeDaemon : NSObject

@property (strong) IBOutlet NSWindow *matchSelectionWindow;
@property (weak) IBOutlet NSPopUpButton *matchSelectionButton;
@property (readonly, strong) DDHotKey *registredHotKey;

+ (instancetype)defaultDaemon;
- (instancetype)init NS_UNAVAILABLE;

- (void)performAutotypeForEntry:(KPKEntry *)entry;
- (IBAction)performAutotypeWithSelectedMatch:(id)sender;
- (IBAction)cancelAutotypeSelection:(id)sender;

@end
