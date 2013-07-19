//
//  Kdb4Entry+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 19.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Entry+MPAdditions.h"

@implementation Kdb4Entry (MPAdditions)

- (NSString *)uniqueKeyForProposal:(NSString *)key {
  /*
   FIXME: Introduce some cachin behaviour. We iterate over after every single edit
   */
  NSArray *defaultKeys = @[ FIELD_TITLE,
                            FIELD_USER_NAME,
                            FIELD_PASSWORD,
                            FIELD_URL,
                            FIELD_NOTES ];
  NSMutableSet *keys = [[NSMutableSet alloc] initWithArray:defaultKeys];
  for(StringField *field in self.stringFields) {
    [keys addObject:field.key];
  }
  NSUInteger counter = 1;
  NSString *base = key;
  while([keys containsObject:key]) {
    key = [NSString stringWithFormat:@"%@-%ld", base, counter++];
  }
  return key;
}

@end
