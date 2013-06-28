//
//  MPCustomFieldTableCellView.h
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPCustomFieldTableCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *labelTextField;
@property (assign) IBOutlet NSTextField *valueTextField;
@property (assign) IBOutlet NSButton *removeButton;

@end
