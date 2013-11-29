//
//  MPAutotypeParser.m
//  MacPass
//
//  Created by Michael Starke on 28/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeParser.h"

#import "NSString+Placeholder.h"

NSString *const kMPAutotypeKeyShift = @"+";
NSString *const kMPAutotypeKeyControl = @"^";
NSString *const kMPAutotypeKeyAlt = @"%";
NSString *const kMPAutotypeKeyEnter = @"~";
NSString *const kMPAutptypeCommandEnter = @"{ENTER}";

@implementation MPAutotypeParser

/*
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
+ (NSArray *)commandsForCommandString:(NSString *)commands {
  NSUInteger commandIndex = 0;
  CGEventFlags modiferKeys = 0;
  while(commandIndex <= [commands length]) {
    /* Modifier Keys
     Shift  +
     Ctrl   ^
     Alt    %
     */
    NSString *currentCommands = [commands substringFromIndex:commandIndex];
    NSCharacterSet *modifierKeySet = [NSCharacterSet characterSetWithCharactersInString:@"+^%"];
    NSRange modifierRange = [currentCommands rangeOfCharacterFromSet:modifierKeySet options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
    if(modifierRange.length != 0 && modifierRange.location == 0) {
      /* starts with a special key */
      if([currentCommands hasPrefix:kMPAutotypeKeyShift]) {
        modiferKeys |= kCGEventFlagMaskAlphaShift;
      }
      if([currentCommands hasPrefix:kMPAutotypeKeyControl]) {
        modiferKeys |= kCGEventFlagMaskControl;
      }
      if([currentCommands hasPrefix:kMPAutotypeKeyAlt]) {
        modiferKeys = kCGEventFlagMaskAlternate;
      }
      /* move the index and continue */
      commandIndex++;
      continue;
    }
    if([currentCommands hasPrefix:@"{"]) {
      /* Commands reset the modifiers */
      modiferKeys = 0;
      NSRange closeBracket = [currentCommands rangeOfString:@"}"];
      if(closeBracket.length == 0) {
        NSLog(@"Syntax error in Autotype Sequence %@ at index: %ld", commands, commandIndex);
        return nil;
      }
      NSString *singleCommand = [currentCommands substringWithRange:NSMakeRange(0, closeBracket.location)];
      
    }
    else {
    
    }
    /* Search on to another bracket or a special key */
    
    /* Command Keys
     Tab              {TAB}
     Enter            {ENTER} or ~
     Arrow Up         {UP}
     Arrow Down       {DOWN}
     Arrow Left       {LEFT}
     Arrow Right      {RIGHT}
     Insert           {INSERT} or {INS}
     Delete           {DELETE} or {DEL}
     Home             {HOME}
     End              {END}
     Page Up          {PGUP}
     Page Down        {PGDN}
     Backspace        {BACKSPACE}, {BS} or {BKSP}
     Break            {BREAK}
     Caps-Lock        {CAPSLOCK}
     Escape           {ESC}
     Windows Key      {WIN} (equ. to {LWIN})
     Windows Key: left, right	{LWIN}, {RWIN}
     Apps / Menu      {APPS}
     Help             {HELP}
     Numlock          {NUMLOCK}
     Print Screen     {PRTSC}
     Scroll Lock      {SCROLLLOCK}
     F1 - F16         {F1} - {F16}
     Numeric Keypad + {ADD}
     Numeric Keypad -	{SUBTRACT}
     Numeric Keypad *	{MULTIPLY}
     Numeric Keypad /	{DIVIDE}
     Numeric Keypad 0 to 9	{NUMPAD0} to {NUMPAD9}
     +                {+}
     ^                {^}
     %                {%}
     ~                {~}
     (, )             {(}, {)}
     [, ]             {[}, {]}
     {, }             {{}, {}} {LCURL}, {RCURL}
     
     */
  }
  return nil;
}

+ (NSString *)_normalizeCommands:(NSString *)commandString {
  /* Cache normalized Commands? */
  NSMutableString *mutableCommand = [commandString mutableCopy];
  [mutableCommand replaceOccurrencesOfString:kMPAutotypeKeyEnter withString:kMPAutptypeCommandEnter options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableCommand length])];
  [mutableCommand replaceOccurrencesOfString:@"{{}" withString:@"{LCURL}" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableCommand length])];
  [mutableCommand replaceOccurrencesOfString:@"{}}" withString:@"{RCURL}" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableCommand length])];
  return nil;
}

@end
