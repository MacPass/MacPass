//
//  MPAutotypePaste.h
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"

/**
 *  Simple Paste action. Uses the Clipboard to copy and then paste contents in place
 */
@interface MPAutotypePaste : MPAutotypeCommand

@property (readonly, copy) NSString *pasteData;

- (instancetype)initWithString:(NSString *)aString;
- (void)appendString:(NSString *)aString;

@end