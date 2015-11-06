//
//  MPContextBarViewController.h
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPDocument.h"

@class HNHUIGradientView;
@class MPDocument;

@interface MPContextBarViewController : MPViewController

@property (weak) IBOutlet NSButton *titleButton;
@property (weak) IBOutlet NSButton *usernameButton;
@property (weak) IBOutlet NSButton *passwordButton;
@property (weak) IBOutlet NSButton *urlButton;
@property (weak) IBOutlet NSButton *notesButton;
@property (weak) IBOutlet NSButton *duplicatePasswordsButton;
@property (weak) IBOutlet NSPopUpButton *specialFilterPopUpButton;

- (void)registerNotificationsForDocument:(MPDocument *)document;

@end
