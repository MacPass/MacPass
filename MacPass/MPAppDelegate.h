//
//  MPAppDelegate.h
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPAppDelegate : NSObject <NSApplicationDelegate>

@property (retain) IBOutlet NSWindow *passwordCreatorWindow;

- (IBAction)showPasswordCreator:(id)sender;

- (NSString *)applicationName;

@end