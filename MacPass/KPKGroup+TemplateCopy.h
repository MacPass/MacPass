//
//  KPKGroup+TemplateCopy.h
//  MacPass
//
//  Created by Michael Starke on 01/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKGroup.h"

@interface KPKGroup (TemplateCopy)

- (instancetype)copyWithName:(NSString *)name;

@end
