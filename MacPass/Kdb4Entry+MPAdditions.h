//
//  Kdb4Entry+MPAdditions.h
//  MacPass
//
//  Created by Michael Starke on 19.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Node.h"

@interface Kdb4Entry (MPAdditions)

- (NSString *)uniqueKeyForProposal:(NSString *)key;

@end
