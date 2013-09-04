//
//  MPSheetWindowController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  Based on
//  DESSheetController  by Peter Nix (pnix@digitalenginesoftware.com)
//

#import <Cocoa/Cocoa.h>
/**
 *	Generic Windowcontroller to be used for sheets
 *  Subclasses are able to initalize their views within updateView
 *  and thus are able to reset themself befor being displayed as sheets
 */
@interface MPSheetWindowController : NSWindowController
/**
 *	Flag to indicate that the view might need resetting.
 *  The default implementation of dismissi sheet and the
 *  designate initalizer both set the value to YES
 */
@property (nonatomic, assign) BOOL isDirty;
/**
 *	This method is a entry point to ensure updated ui befor being presented
 *  The method is called every time the window message is sent to the controller
 */
- (void)updateView;

- (void)dismissSheet:(NSInteger)returnCode;

@end
