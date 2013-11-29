//
//  MPAutotypeCommand.m
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"
#import "NSString+Commands.h"

#import <Carbon/Carbon.h>

@implementation MPAutotypeCommand

- (void)sendPressKey:(CGKeyCode)keyCode modifierFlags:(CGEventFlags)flags {
  CGEventRef pressKey = CGEventCreateKeyboardEvent (NULL, keyCode, YES);
  CGEventRef releaseKey = CGEventCreateKeyboardEvent (NULL, keyCode, NO);
  
  CGEventSetFlags(pressKey,0);
  CGEventSetFlags(releaseKey, 0);
  CGEventSetFlags(pressKey,flags);
  CGEventSetFlags(releaseKey, flags);
  
  CGEventPost(kCGSessionEventTap, pressKey);
  CGEventPost(kCGSessionEventTap, releaseKey);
  
  CFRelease(pressKey);
  CFRelease(releaseKey);
}

/*
 cody by Joe Turner http://www.cocoabuilder.com/archive/cocoa/242992-detect-keyboard-layout-for-cgkeycodes.html#243168
 */
- (CGKeyCode)keyCodeForKeyboard:(const UCKeyboardLayout *)uchrHeader character:(NSString *)character {
  if ([character isEqualToString:@"RETURN"]) return kVK_Return;
  if ([character isEqualToString:@"TAB"]) return kVK_Tab;
  if ([character isEqualToString:@"SPACE"]) return kVK_Space;
  if ([character isEqualToString:@"DELETE"]) return kVK_Delete;
  if ([character isEqualToString:@"ESCAPE"]) return kVK_Escape;
  if ([character isEqualToString:@"F5"]) return kVK_F5;
  if ([character isEqualToString:@"F6"]) return kVK_F6;
  if ([character isEqualToString:@"F7"]) return kVK_F7;
  if ([character isEqualToString:@"F3"]) return kVK_F3;
  if ([character isEqualToString:@"F8"]) return kVK_F8;
  if ([character isEqualToString:@"F9"]) return kVK_F9;
  if ([character isEqualToString:@"F11"]) return kVK_F11;
  if ([character isEqualToString:@"F13"]) return kVK_F13;
  if ([character isEqualToString:@"F16"]) return kVK_F16;
  if ([character isEqualToString:@"F14"]) return kVK_F14;
  if ([character isEqualToString:@"F10"]) return kVK_F10;
  if ([character isEqualToString:@"F12"]) return kVK_F12;
  if ([character isEqualToString:@"F15"]) return kVK_F15;
  if ([character isEqualToString:@"HELP"]) return kVK_Help;
  if ([character isEqualToString:@"HOME"]) return kVK_Home;
  if ([character isEqualToString:@"PAGE UP"]) return kVK_PageUp;
  if ([character isEqualToString:@"FORWARD DELETE"]) return kVK_ForwardDelete;
  if ([character isEqualToString:@"F4"]) return kVK_F4;
  if ([character isEqualToString:@"END"]) return kVK_End;
  if ([character isEqualToString:@"F2"]) return kVK_F2;
  if ([character isEqualToString:@"PAGE DOWN"]) return kVK_PageDown;
  if ([character isEqualToString:@"F1"]) return kVK_F1;
  if ([character isEqualToString:@"LEFT"]) return kVK_LeftArrow;
  if ([character isEqualToString:@"RIGHT"]) return kVK_RightArrow;
  if ([character isEqualToString:@"DOWN"]) return kVK_DownArrow;
  if ([character isEqualToString:@"UP"]) return kVK_UpArrow;
  
  UTF16Char theCharacter = [character characterAtIndex:0];
  long i, j, k;
  unsigned char *uchrData = (unsigned char *)uchrHeader;
  UCKeyboardTypeHeader *uchrTable = uchrHeader->keyboardTypeList;
  BOOL found = NO;
  UInt16 virtualKeyCode;
  
  for (i = 0; i < (uchrHeader->keyboardTypeCount) && !found; i++) {
    UCKeyToCharTableIndex *uchrKeyIX;
    UCKeyStateRecordsIndex *stateRecordsIndex;
    
    if (uchrTable[i].keyStateRecordsIndexOffset != 0 ) {
      stateRecordsIndex = (UCKeyStateRecordsIndex *) (((unsigned char*)uchrData) + (uchrTable[i].keyStateRecordsIndexOffset));
      
      if ((stateRecordsIndex->keyStateRecordsIndexFormat) != kUCKeyStateRecordsIndexFormat) {
        stateRecordsIndex = NULL;
      }
    }
    else {
      stateRecordsIndex = NULL;
    }
    
    uchrKeyIX = (UCKeyToCharTableIndex *)(((unsigned char *)uchrData) + (uchrTable[i].keyToCharTableIndexOffset));
    
    if (kUCKeyToCharTableIndexFormat == (uchrKeyIX-> keyToCharTableIndexFormat)) {
      for (j = 0; j < (uchrKeyIX->keyToCharTableCount) && !found; j++) {
        UCKeyOutput *keyToCharData = (UCKeyOutput *) ( ((unsigned char*)uchrData) + (uchrKeyIX->keyToCharTableOffsets[j]) );
        
        for (k = 0; k < (uchrKeyIX->keyToCharTableSize) && !found; k++) {
          if (((keyToCharData[k]) & kUCKeyOutputTestForIndexMask) == kUCKeyOutputStateIndexMask) {
            long theIndex = (kUCKeyOutputGetIndexMask & keyToCharData[k]);
            
            if (stateRecordsIndex != NULL && theIndex <= stateRecordsIndex-> keyStateRecordCount) {
              UCKeyStateRecord *theStateRecord = (UCKeyStateRecord *) (((unsigned char *) uchrData) + (stateRecordsIndex-> keyStateRecordOffsets[theIndex]));
              
              if ((theStateRecord->stateZeroCharData) == theCharacter) {
                virtualKeyCode = k;
                found = YES;
              }
            } else {
              if ((keyToCharData[k]) == theCharacter) {
                virtualKeyCode = k;
                found = YES;
              }
            }
          } else if (((keyToCharData[k]) & kUCKeyOutputTestForIndexMask) == kUCKeyOutputSequenceIndexMask) {
          } else if ( (keyToCharData[k]) == 0xFFFE ||  (keyToCharData[k]) == 0xFFFF ) {
          } else {
            if ((keyToCharData[k]) == theCharacter) {
              virtualKeyCode = k;
              found = YES;
            }
          }
        }
      }
    }
  }
  return (CGKeyCode)virtualKeyCode;
}

- (void)executeWithEntry:(KPKEntry *)entry {
  NSAssert(NO, @"Not Implemented");
}

@end
