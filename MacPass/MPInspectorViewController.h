//
//  MPInspectorTabViewController.h
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class  MPPopupImageView;

@interface MPInspectorViewController : MPViewController

@property (assign) IBOutlet MPPopupImageView *itemImageView;
@property (assign) IBOutlet NSTextField *itemNameTextfield;

@property (assign) IBOutlet NSTextField *titleTextField;
@property (assign) IBOutlet NSTextField *usernameTextField;
@property (assign) IBOutlet NSTextField *URLTextField;
@property (assign) IBOutlet NSTextField *passwordTextField;
@property (assign) IBOutlet NSTextField *titleOrNameLabel;

@property (assign) IBOutlet NSButton *openURLButton;
@property (assign) IBOutlet NSButton *showPasswordCreator;

- (BOOL)isVisible;
- (void)hideImagePopup:(id)sender;

@end
