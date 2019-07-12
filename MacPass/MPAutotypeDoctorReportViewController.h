//
//  MPAutotypeDoctorReportViewController.h
//  MacPass
//
//  Created by Michael Starke on 05.07.19.
//  Copyright © 2019 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPAutotypeDoctorReportViewController : NSViewController

@property (strong) IBOutlet NSImageView *accessibiltyStatusImageView;
@property (strong) IBOutlet NSTextField *accessibiltyStatusTextField;

@property (strong) IBOutlet NSImageView *screenRecordingStatusImageView;
@property (strong) IBOutlet NSTextField *screenRecordingStatusTextField;

- (IBAction)openAccessibiltyPreferences:(id)sender;
- (IBAction)openScreenRecordingPreferences:(id)sender;
- (IBAction)openAutomationPreferences:(id)sender;


@end

NS_ASSUME_NONNULL_END
