//
//  MPResponderQuery.h
//  MacPass
//
//  Created by Michael Starke on 11.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPResponderQuery <NSObject>
@required
- (BOOL)containsFirstResponder;

@end
