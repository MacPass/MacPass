//
//  StringField+Validation.m
//  MacPass
//
//  Created by Michael Starke on 19.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "StringField+Validation.h"
#import "Kdb4Entry+MPAdditions.h"

@implementation StringField (Validation)

- (BOOL)validateValue:(inout __autoreleasing id *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing *)outError {
  *ioValue = [self.entry uniqueKeyForProposal:*ioValue];
  return YES;
}

@end
