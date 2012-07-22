//
//  MPAppDelegate.h
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

APPKIT_EXTERN NSString *const kOutlineViewIdentifier;

@class MPDatabaseDocument;

@interface MPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, retain) MPDatabaseDocument *database;

@end
