//
//  NSIndexPath+MPAdditions.h
//  MacPass
//
//  Created by Michael Starke on 07.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSIndexPath (MPAdditions)

- (BOOL)containsIndexPath:(NSIndexPath *)path;

@end

NS_ASSUME_NONNULL_END
