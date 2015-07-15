//
//  MPPasswordEditWindowController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPSheetWindowController.h"
@class MPDocument;
@class HNHRoundedSecureTextField;

@protocol MPPasswordEditWindowDelegate <NSObject>

@optional
/**
 *	Get's called on dismissing the password editor.
 *	@param	changedPasswordOrKey	YES if the password and/or key was saved (not necessairly changed!);
 */
- (void)didFinishPasswordEditing:(BOOL)changedPasswordOrKey;

@end

@interface MPPasswordEditWindowController : MPSheetWindowController <NSTextFieldDelegate>

@property (weak) IBOutlet HNHRoundedSecureTextField *passwordTextField;
@property (weak) IBOutlet HNHRoundedSecureTextField *passwordRepeatTextField;
@property (weak) IBOutlet NSPathControl *keyfilePathControl;
@property (weak) IBOutlet NSButton *togglePasswordButton;
@property (weak) IBOutlet NSTextField *errorTextField;
@property (weak) IBOutlet NSButton *changePasswordButton;
@property (weak) IBOutlet NSButton *hasPasswordSwitchButton;

//@property (nonatomic,assign) BOOL allowsEmptyPasswordOrKey;
@property (weak) id<MPPasswordEditWindowDelegate> delegate;

- (IBAction)clearKey:(id)sender;
- (IBAction)generateKey:(id)sender;


@end
