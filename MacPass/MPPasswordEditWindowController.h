//
//  MPPasswordEditWindowController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HNHUi/HNHUi.h>

@class MPDocument;
@class HNHUIRoundedSecureTextField;

@protocol MPPasswordEditWindowDelegate <NSObject>

@optional
/**
 *	Get's called on dismissing the password editor.
 *	@param	changedPasswordOrKey	YES if the password and/or key was saved (not necessarily changed!);
 */
- (void)didFinishPasswordEditing:(BOOL)changedPasswordOrKey;

@end

@interface MPPasswordEditWindowController : HNHUISheetWindowController <NSTextFieldDelegate>

@property (weak) IBOutlet HNHUIRoundedSecureTextField *passwordTextField;
@property (weak) IBOutlet HNHUIRoundedSecureTextField *passwordRepeatTextField;
@property (weak) IBOutlet NSPathControl *keyfilePathControl;
@property (weak) IBOutlet NSButton *togglePasswordButton;
@property (weak) IBOutlet NSTextField *errorTextField;
@property (weak) IBOutlet NSButton *changePasswordButton;
@property (weak) IBOutlet NSButton *hasPasswordSwitchButton;

//@property (nonatomic,assign) BOOL allowsEmptyPasswordOrKey;
//@property (weak) id<MPPasswordEditWindowDelegate> delegate;

- (IBAction)clearKey:(id)sender;
- (IBAction)generateKey:(id)sender;


@end
