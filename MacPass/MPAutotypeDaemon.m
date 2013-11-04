//
//  MPAutotypeDaemon.m
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDaemon.h"
#import "DDHotKeyCenter.h"
#import "MPPasteBoardController.h"
#import "MPDocument.h"

#import "KPKEntry.h"

#import <Carbon/Carbon.h>

/*
 
 Autotype workflow:

 run copy/paste with content
 
 special keys:
 
 Tab	{TAB}
 Enter	{ENTER} or ~
 Arrow Up	{UP}
 Arrow Down	{DOWN}
 Arrow Left	{LEFT}
 Arrow Right	{RIGHT}
 Insert	{INSERT} or {INS}
 Delete	{DELETE} or {DEL}
 Home	{HOME}
 End	{END}
 Page Up	{PGUP}
 Page Down	{PGDN}
 Backspace	{BACKSPACE}, {BS} or {BKSP}
 Break	{BREAK}
 Caps-Lock	{CAPSLOCK}
 Escape	{ESC}
 Windows Key	{WIN} (equ. to {LWIN})
 Windows Key: left, right	{LWIN}, {RWIN}
 Apps / Menu	{APPS}
 Help	{HELP}
 Numlock	{NUMLOCK}
 Print Screen	{PRTSC}
 Scroll Lock	{SCROLLLOCK}
 F1 - F16	{F1} - {F16}
 Numeric Keypad +	{ADD}
 Numeric Keypad -	{SUBTRACT}
 Numeric Keypad *	{MULTIPLY}
 Numeric Keypad /	{DIVIDE}
 Numeric Keypad 0 to 9	{NUMPAD0} to {NUMPAD9}
 Shift	+
 Ctrl	^
 Alt	%
 +	{+}
 ^	{^}
 %	{%}
 ~	{~}
 (, )	{(}, {)}
 [, ]	{[}, {]}
 {, }	{{}, {}}
 
 special commands:
 
 {DELAY X}	Delays X milliseconds.
 {CLEARFIELD}	Clears the contents of the edit control that currently has the focus (only single-line edit controls).
 {VKEY X}
 */

@implementation MPAutotypeDaemon

- (id)init {
  self = [super init];
  if (self) {
    /*
     Test the system for enabled access for assistive devices. Otherwise we cannot work properly
     
     Use defaults to determine if global hotkey is enabled
    [self _registerHotKey];
     */
  }
  return self;
}

- (void)didPressHotKey {
  // copy items to pasteboard
  NSArray *documents = [NSApp orderedDocuments];
  MPDocument *currentDocument = nil;
  for(MPDocument *openDocument in documents) {
    if(NO == openDocument.encrypted) {
      currentDocument = openDocument;
      break;
    }
  }
  
  /*
   Determine the window title of  the current front most application
   Start searching the db for the best fit (based on title, then on window associations
   */
  NSString *windowTitle = [self _frontMostWindowTitle];
  NSLog(@"Looking for entries matching window title:%@", windowTitle);
  
  return;
  
  KPKEntry *selectedEntry = currentDocument.selectedEntry;
  if(nil == currentDocument || nil == selectedEntry) {
    return; // no open documents, no selected entry
  }
  
  /* TODO:
   Replace entry based palce holders
   Replace global placeholders
   Translate to paste/copy commands
   Find correct key-codes for current keyboard layout to perform paste command
   */
  MPPasteBoardController *controller = [MPPasteBoardController defaultController];
  if(selectedEntry.username) {
    [controller copyObjects:@[selectedEntry.username]];
    [self _pressKey:kVK_ANSI_V modifierFlags:kCGEventFlagMaskCommand];
  }
  if(selectedEntry.password) {
    [self _pressKey:kVK_Tab modifierFlags:0];
    [controller copyObjects:@[selectedEntry.password]];
    [self _pressKey:kVK_ANSI_V modifierFlags:kCGEventFlagMaskCommand];
  }
  [self _pressKey:kVK_Return modifierFlags:0];
}

- (void)_registerHotKey {
  [[DDHotKeyCenter sharedHotKeyCenter] registerHotKeyWithKeyCode:kVK_ANSI_M
                                                   modifierFlags:(NSCommandKeyMask | NSAlternateKeyMask )
                                                          target:self
                                                          action:@selector(didPressHotKey)
                                                          object:nil];
}

- (void)_pressKey:(CGKeyCode)keyCode modifierFlags:(CGEventFlags)flags {
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

- (NSString *)_frontMostWindowTitle {
  NSRunningApplication *frontApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
  
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  for(NSDictionary *windowDict in currentWindows) {
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(frontApplication.processIdentifier)]) {
      return windowDict[(NSString *)kCGWindowName];
    }
  }
  return nil;
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


@end
