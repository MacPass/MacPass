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

@protocol MPTOTPViewControllerDelegate <NSObject>

@optional
- (void)didCopyTOTPString:(NSString *)string;

@end

@interface MPTOTPViewController : NSViewController
@property (strong) IBOutlet HNHUITextField *toptValueTextField;
@property (strong) IBOutlet NSButton *remainingTimeButton;
@property (strong) IBOutlet NSButton *showSetupButton;
@property (nullable, weak) id<MPTOTPViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
