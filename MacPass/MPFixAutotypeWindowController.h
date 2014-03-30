//
//  MPFixAutotypeWindowController.h
//  MacPass
//
//  Created by Michael Starke on 26/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MPDocument;

@interface MPFixAutotypeWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) MPDocument *workingDocument;

/**
 *  Clears the autotype sequences for the selected entries, groups or window associations
 *
 *  @param sender sender of the action
 */
- (IBAction)clearAutotype:(id)sender;

@end
