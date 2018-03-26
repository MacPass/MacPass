//
//  MPPlugin+Private.h
//  MacPass
//
//  Created by Michael Starke on 20.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPPlugin.h"

@interface MPPlugin ()

@property (nonatomic, strong) NSBundle *bundle;
@property (copy) NSString *errorMessage;
@property BOOL enabled;

@end
