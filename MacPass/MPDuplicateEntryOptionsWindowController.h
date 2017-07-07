//
//  MPDuplicateEntryOptionsWindowController.h
//  MacPass
//
//  Created by Michael Starke on 08.06.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPDuplicateEntryOptionsWindowController : NSWindowController

@property (readonly) BOOL referencePassword;
@property (readonly) BOOL referenceUsername;
@property (readonly) BOOL duplicateHistory;

@end
