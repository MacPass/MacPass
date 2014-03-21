//
//  MPAutotypeDaemon.h
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPKEntry;

/**
 *  The autotype daemon is repsonsible for registering the globa hotkey and to perform any autotype actions
 */
@interface MPAutotypeDaemon : NSObject

@property (strong) IBOutlet NSWindow *matchSelectionWindow;
@property (weak) IBOutlet NSPopUpButton *matchSelectionButton;
@property (weak) IBOutlet NSButton *performAutotypeButton;

- (void)exectureAutotypeForEntry:(KPKEntry *)entry withWindowTitle:(NSString *)title;

@end
