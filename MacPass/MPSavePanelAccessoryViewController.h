//
//  MPSavePanelAccessoryViewController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
@class MPDocument;

@interface MPSavePanelAccessoryViewController : MPViewController

@property (nonatomic, assign) NSSavePanel *savePanel;
@property (nonatomic, assign) MPDocument *document;

@property (nonatomic, weak) IBOutlet NSPopUpButton *fileTypePopupButton;
@property (nonatomic, weak) IBOutlet NSTextField *infoTextField;

@end
