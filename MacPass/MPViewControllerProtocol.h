//
//  MPViewControllerProtocol.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPViewControllerProtocol <NSObject>

@required
- (NSResponder *)reconmendetFirstResponder;

@end
