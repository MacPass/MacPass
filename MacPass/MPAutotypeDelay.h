//
//  MPAutotypeDelay.h
//  MacPass
//
//  Created by Michael Starke on 20/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"

@interface MPAutotypeDelay : MPAutotypeCommand

@property (readonly) NSUInteger delay;
/**
 *  Creates an DelayCommand that delays the execution for n milliseconds
 *
 *  @param delay Delay in milliseconds
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithDelay:(NSUInteger)delay;

@end
