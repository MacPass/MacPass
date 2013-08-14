//
//  MPAppDelegate.h
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet NSWindow *passwordCreatorWindow;
@property (strong) IBOutlet NSWindow *welcomeWindow;

- (IBAction)showPasswordCreator:(id)sender;
- (IBAction)createNewDatabase:(id)sender;
- (IBAction)openDatabase:(id)sender;

- (NSString *)applicationName;
- (void)lockAllDocuments;

@end