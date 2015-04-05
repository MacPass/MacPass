//
//  MPSavePanelAccessoryViewController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "KPKVersion.h"

@class MPDocument;

@interface MPSavePanelAccessoryViewController : MPViewController

@property (nonatomic, weak) NSSavePanel *savePanel;
@property (nonatomic, weak) MPDocument *document;
@property (nonatomic, assign, readonly) KPKVersion selectedVersion;

@property (nonatomic, weak) IBOutlet NSPopUpButton *fileTypePopupButton;
@property (nonatomic, weak) IBOutlet NSTextField *infoTextField;
/**
 *	Updates the view to current state
 */
- (void)updateView;

@end
