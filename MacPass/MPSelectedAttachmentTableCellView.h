//
//  MPSelectedAttachmentTableCellView.h
//  MacPass
//
//  Created by Michael Starke on 03.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* Simple View with an additional Button to add an Action to selected rows */
@interface MPSelectedAttachmentTableCellView : NSTableCellView

@property (nonatomic, assign) IBOutlet NSButton *saveButton;

@end
