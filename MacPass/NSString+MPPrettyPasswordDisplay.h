//
//  NSString+MPPrettyPasswordDisplay.h
//  MacPass
//
//  Created by Michael Starke on 30.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MPPrettyPasswordDisplay)

@property (copy) NSAttributedString *passwordPrettified;

@end
