//
//  MPPluginVersion.m
//  MacPass
//
//  Created by Michael Starke on 05.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//
//  Code is based upon SUStandardVersionComparator.h from Sparkle
//  Changes include:
//  * wildcard matching
//  * correct handling of trailing parts (e.g. 3. == 3.0 == 3.0.0)
//

#import "MPPluginVersionComparator.h"

@implementation MPPluginVersionComparator

+ (MPVersionCharacterType)typeOfCharacter:(NSString *)character {
  if([character isEqualToString:@"."]) {
    return kMPVersionCharacterTypeSeparator;
  }
  if([character isEqualToString:@"*"]) {
    return kMPVersionCharacterTypeWildcard;
  }
  else if([NSCharacterSet.decimalDigitCharacterSet characterIsMember:[character characterAtIndex:0]]) {
    return kMPVersionCharacterTypeNumeric;
  }
  else if([NSCharacterSet.whitespaceAndNewlineCharacterSet characterIsMember:[character characterAtIndex:0]]) {
    return kMPVersionCharacterTypeSeparator;
  }
  else if([NSCharacterSet.punctuationCharacterSet characterIsMember:[character characterAtIndex:0]]) {
    return kMPVersionCharacterTypeSeparator;
  }
  return kMPVersionCharacterTypeString;
}

+ (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB {
  NSArray<NSString *>* partsA = [self splitVersionString:versionA];
  NSArray<NSString *>* partsB = [self splitVersionString:versionB];
  
  
  MPVersionCharacterType typeA;
  MPVersionCharacterType typeB;
  
  NSUInteger minPartsCount = MIN(partsA.count, partsB.count);
  if(minPartsCount == 0) {
    if(partsA.count == 0) {
      return NSOrderedAscending;
    }
    return NSOrderedDescending;
  }
  for(NSUInteger index = 0; index < minPartsCount; index++) {
    
    NSString *partA = partsA[index];
    NSString *partB = partsB[index];
    
    typeA = [self typeOfCharacter:partA];
    typeB = [self typeOfCharacter:partB];
    
    if(typeA == typeB) {
      if(typeA == kMPVersionCharacterTypeNumeric) {
        NSInteger valueA = partA.integerValue;
        NSInteger valueB = partB.integerValue;
        if(valueA < valueB) {
          return NSOrderedAscending;
        }
        else if (valueA > valueB) {
          return NSOrderedDescending;
        }
      }
      else if(typeA == kMPVersionCharacterTypeString) {
        NSComparisonResult stringCompare = [partA compare:partB];
        if(stringCompare != NSOrderedSame) {
          return stringCompare;
        }
      }
    }
    else {
      /* no wildcards, direct compare */
      if(typeA != kMPVersionCharacterTypeWildcard && typeB != kMPVersionCharacterTypeWildcard) {
        if(typeA != kMPVersionCharacterTypeString && typeB == kMPVersionCharacterTypeString) {
          return NSOrderedDescending;
        }
        else if(typeA == kMPVersionCharacterTypeString && typeB != kMPVersionCharacterTypeString) {
          return NSOrderedAscending;
        }
        else {
          if(typeA == kMPVersionCharacterTypeNumeric) {
            return NSOrderedDescending;
          }
          else {
            return NSOrderedAscending;
          }
        }
      }
      /* we have at least one wildcards */
      else {
        /* one is separator, separator wins*/
        if(typeA == kMPVersionCharacterTypeSeparator) {
          return NSOrderedDescending;
        }
        else if(typeB == kMPVersionCharacterTypeSeparator) {
          return NSOrderedAscending;
        }
        /* one is number or string, gets matched by wildcard */
      }
    }
  }
  if(partsA.count != partsB.count) {
    NSArray *longerParts;
    NSComparisonResult shorterResult;
    NSComparisonResult longerResult;
    MPVersionCharacterType lastShortType;
    if(partsA.count > partsB.count) {
      lastShortType = typeB;
      longerParts = partsA;
      shorterResult = NSOrderedAscending;
      longerResult = NSOrderedDescending;
    }
    else {
      lastShortType = typeA;
      longerParts = partsB;
      shorterResult = NSOrderedDescending;
      longerResult = NSOrderedAscending;

    }
    /* check if wildcard was last part of shorter version, then the rest does not matter */
    if(lastShortType == kMPVersionCharacterTypeWildcard) {
      return NSOrderedSame;
    }
    for(NSUInteger longerPartsIndex = minPartsCount; longerPartsIndex < longerParts.count; longerPartsIndex++) {
      NSString *part = longerParts[longerPartsIndex];
      MPVersionCharacterType type = [self typeOfCharacter:part];
      /* overhangpart is string, the shorter wins */
      if(type == kMPVersionCharacterTypeString) {
        return shorterResult;
      }
      /* overhangpart is number, if not null, longer wins */
      else if(type == kMPVersionCharacterTypeNumeric) {
        if(part.integerValue != 0) {
          return longerResult;
        }
      }
      /* Any separator or widlcard that is in the longer version is skippes since we do not have to match components anymore */
    }
  }
  return NSOrderedSame;
}

+ (NSArray<NSString *> *)splitVersionString:(NSString *)versionString {
  if(versionString.length == 0) {
    return @[];
  }
  NSMutableArray *versionSegements = [[NSMutableArray alloc] init];
  NSMutableString *currentSegment = [[versionString substringWithRange:NSMakeRange(0, 1)] mutableCopy];
  MPVersionCharacterType oldType = [self typeOfCharacter:currentSegment];

  for(NSUInteger characterIndex = 1; characterIndex < versionString.length; characterIndex++) {
    NSString *character = [versionString substringWithRange:NSMakeRange(characterIndex, 1)];
    MPVersionCharacterType newType = [self typeOfCharacter:character];
    if(oldType != newType || newType == kMPVersionCharacterTypeSeparator) {
      [versionSegements addObject:[currentSegment copy]];
      [currentSegment setString:character];
    }
    else {
      [currentSegment appendString:character];
    }
    oldType = newType;
  }
  [versionSegements addObject:[currentSegment copy]];
  return [versionSegements copy];
}



@end
