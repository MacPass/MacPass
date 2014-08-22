//
//  MPDatePickingViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@interface MPDatePickingViewController : MPViewController

@property (strong,readonly) NSDate *date;
@property (weak) IBOutlet NSDatePicker *datePicker;
@property (weak) IBOutlet NSPopUpButton *presetPopupButton;
@property (assign, readonly) BOOL didCancel;

- (IBAction)useDate:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)setDatePreset:(id)sender;

@end
