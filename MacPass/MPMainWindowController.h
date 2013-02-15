//
//  MPMainWindowController.h
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

APPKIT_EXTERN NSString *const MPMainWindowControllerPasswordKey;
APPKIT_EXTERN NSString *const MPMainWindowControllerKeyfileKey;

@class MPDatabaseDocument;

@interface MPMainWindowController : NSWindowController

@property (readonly, retain) MPDatabaseDocument *database;

- (void)presentPasswordInput:(NSURL *)file;

@end
