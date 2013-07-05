//
//  MPCustomFieldTableCellView.h
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPCustomFieldTableCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField *labelTextField;
@property (nonatomic, weak) IBOutlet NSTextField *valueTextField;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;

@end
