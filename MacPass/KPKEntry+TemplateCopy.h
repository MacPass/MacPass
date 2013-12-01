//
//  KPKEntry+TemplateCopy.h
//  MacPass
//
//  Created by Michael Starke on 01/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKEntry.h"

@interface KPKEntry (TemplateCopy)

- (instancetype)copyWithTitle:(NSString *)title;

@end
