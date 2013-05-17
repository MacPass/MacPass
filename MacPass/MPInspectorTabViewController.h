//
//  MPInspectorTabViewController.h
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class  MPPopupImageView;

@interface MPInspectorTabViewController : MPViewController

@property (assign) IBOutlet MPPopupImageView *itemImageView;
@property (assign) IBOutlet NSTextField *itemNameTextfield;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSSegmentedControl *tabControl;

@property (assign) IBOutlet NSTextField *titleTextField;
@property (assign) IBOutlet NSTextField *usernameTextField;
@property (assign) IBOutlet NSTextField *URLTextField;
@property (assign) IBOutlet NSSecureTextField *passwordTextField;
@property (assign) IBOutlet NSTextField *titleOrNameLabel;

@property (assign) IBOutlet NSButton *openURLButton;
@property (assign) IBOutlet NSButton *showPasswordCreator;

- (void)toggleVisible;
- (IBAction)togglePasswordDisplay:(id)sender;
- (void)hideImagePopup:(id)sender;

@end
