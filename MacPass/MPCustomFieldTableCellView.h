//
//  MPCustomFieldTableCellView.h
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPCustomFieldTableCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *labelTextField;
@property (weak) IBOutlet NSTextField *valueTextField;
@property (weak) IBOutlet NSButton *removeButton;

@end
