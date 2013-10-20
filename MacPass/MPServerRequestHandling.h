//
//  MPServerRequestHandler.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPServerRequestHandling <NSObject>

@required
- (NSString *)identifier;
- (void)respondTo:(NSDictionary *)data;

@end
