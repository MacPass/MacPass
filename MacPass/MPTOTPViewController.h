//
//  MPOTPViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HNHUi/HNHUi.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPTOTPViewController : NSViewController <HNHUITextFieldDelegate>
@property (strong) IBOutlet HNHUITextField *toptValueTextField;
@property (strong) IBOutlet NSButton *remainingTimeButton;
@property (strong) IBOutlet NSButton *showSetupButton;

@end

NS_ASSUME_NONNULL_END
