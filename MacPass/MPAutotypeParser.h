//
//  MPAutotypeParser.h
//  MacPass
//
//  Created by Michael Starke on 28/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAutotypeParser : NSObject

+ (NSArray *)commandsForCommandString:(NSString *)commands;

@end
