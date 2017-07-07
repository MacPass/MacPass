//
//  MPModifiedKey.h
//  MacPass
//
//  Created by Michael Starke on 26/01/2017.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
  CGEventFlags modifier;
  CGKeyCode keyCode;
} MPModifiedKey;

NS_INLINE MPModifiedKey MPMakeModifiedKey(CGEventFlags modifier, CGKeyCode keyCode) {
  MPModifiedKey k;
  k.keyCode = keyCode;
  k.modifier = modifier;
  return k;
}

@interface NSValue(NSValueMPModifiedKeyExtensions)
@property (nonatomic, readonly, assign) MPModifiedKey modifiedKeyValue;
+ (instancetype)valueWithModifiedKey:(MPModifiedKey)key;
@end
