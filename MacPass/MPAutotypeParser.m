//
//  MPAutotypeParser.m
//  MacPass
//
//  Created by Michael Starke on 02.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeParser.h"
#import "MPAutotypeClear.h"
#import "MPAutotypeContext.h"
#import "MPAutotypeDelay.h"
#import "MPAutotypeKeyPress.h"
#import "MPAutotypePaste.h"
#import "MPKeyMapper.h"
#import "MPFlagsHelper.h"
#import "MPSettingsHelper.h"

#import "NSString+MPComposedCharacterAdditions.h"

#import <KeePassKit/KeePassKit.h>

#import <Carbon/Carbon.h>
#import <CommonCrypto/CommonCrypto.h>

static CGKeyCode kMPFunctionKeyCodes[] = {
  kVK_F1,
  kVK_F2,
  kVK_F3,
  kVK_F4,
  kVK_F5,
  kVK_F6,
  kVK_F7,
  kVK_F8,
  kVK_F9,
  kVK_F10,
  kVK_F11,
  kVK_F12,
  kVK_F13,
  kVK_F14,
  kVK_F15,
  kVK_F16,
  kVK_F17,
  kVK_F18,
  kVK_F19
};

static CGKeyCode kMPNumpadKeyCodes[] = {
  kVK_ANSI_Keypad0,
  kVK_ANSI_Keypad1,
  kVK_ANSI_Keypad2,
  kVK_ANSI_Keypad3,
  kVK_ANSI_Keypad4,
  kVK_ANSI_Keypad5,
  kVK_ANSI_Keypad6,
  kVK_ANSI_Keypad7,
  kVK_ANSI_Keypad8,
  kVK_ANSI_Keypad9
};

@interface NSNumber (AutotypeCommand)

@property (nonatomic, readonly, assign) CGEventFlags eventFlagsValue;
@property (nonatomic, readonly, assign) CGKeyCode keyCodeValue;

@end

@implementation NSNumber (AutotypeCommand)

- (CGEventFlags)eventFlagsValue {
  return (CGEventFlags)self.integerValue;
}
- (CGKeyCode)keyCodeValue {
  return (CGKeyCode)self.integerValue;
}

@end


@interface MPAutotypeParser ()

@property (strong) NSMutableArray<MPAutotypeCommand *> *mutableCommands;
@property (strong, nonatomic, readonly) NSDictionary *keyPressCommands;
@property (strong, nonatomic, readonly) NSDictionary *characterCommands;
@property (strong, nonatomic, readonly) NSDictionary *modifierCommands;

@end

@implementation MPAutotypeParser

@dynamic commands;
@dynamic keyPressCommands;
@dynamic characterCommands;
@dynamic modifierCommands;

- (NSDictionary *)keypressCommands {
  static NSDictionary *keypressCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    keypressCommands = @{ kKPKAutotypeBackspace : @(kVK_Delete),
                          //kKPKAutotypeBreak : @0,
                          kKPKAutotypeCapsLock : @(kVK_CapsLock),
                          kKPKAutotypeDelete : @(kVK_ForwardDelete),
                          kKPKAutotypeDown : @(kVK_DownArrow),
                          kKPKAutotypeEnd : @(kVK_End),
                          kKPKAutotypeEnter : @(kVK_Return),
                          kKPKAutotypeEscape : @(kVK_Escape),
                          kKPKAutotypeHelp : @(kVK_Help),
                          kKPKAutotypeHome : @(kVK_Home),
                          //kKPKAutotypeInsert : @(),
                          kKPKAutotypeLeft : @(kVK_LeftArrow),
                          kKPKAutotypeLeftWindows : @(kVK_Command),
                          //kKPKAutotypeNumlock : @(),
                          kKPKAutotypePageDown : @(kVK_PageDown),
                          kKPKAutotypePageUp : @(kVK_PageUp),
                          //kKPKAutotypePrintScreen : @(),
                          kKPKAutotypeRight : @(kVK_RightArrow),
                          kKPKAutotypeRightWindows : @(kVK_Command),
                          //kKPKAutotypeScrollLock : @(),
                          kKPKAutotypeSpace : @(kVK_Space),
                          kKPKAutotypeTab : @(kVK_Tab),
                          kKPKAutotypeUp : @(kVK_UpArrow),
                          kKPKAutotypeWindows : @(kVK_Command)
                          };
  });
  return keypressCommands;
}
/* Commands that are actually just one symbol to be pasted */
- (NSDictionary *)characterCommands {
  static NSDictionary *characterCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    characterCommands = @{
                          kKPKAutotypePlus: @"+",
                          kKPKAutotypeCaret: @"^",
                          kKPKAutotypePercent: @"%",
                          kKPKAutotypeTilde : @"~",
                          kKPKAutotypeRoundBracketLeft : @"(",
                          kKPKAutotypeRoundBracketRight : @")",
                          kKPKAutotypeSquareBracketLeft : @"[",
                          kKPKAutotypeSquareBracketRight : @"]",
                          kKPKAutotypeCurlyBracketLeft: @"{",
                          kKPKAutotypeCurlyBracketRight: @"}"
                          };
  });
  return characterCommands;
}

/**
 *  Mapping for modifier to CGEventFlags.
 *
 *  @return dictionary with commands as keys and CGEventFlags as wrapped values
 */
- (NSDictionary *)modifierCommands {
  static NSDictionary *modifierCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    modifierCommands = @{
                         kKPKAutotypeAlt : @(kCGEventFlagMaskAlternate),
                         kKPKAutotypeControl : @(kCGEventFlagMaskControl),
                         kKPKAutotypeShift : @(kCGEventFlagMaskShift)
                         };
  });
  return modifierCommands;
}


- (instancetype)initWithContext:(MPAutotypeContext *)context {
  self = [super init];
  if(self) {
    _context = context;
  }
  return self;
}

- (NSArray<MPAutotypeCommand *> *)commands {
  if(!self.mutableCommands) {
    [self _parseCommands];
  }
  return [self.mutableCommands copy];
}

- (void)_parseCommands {
  if(!self.context.valid) {
    return;
  }
  NSUInteger reserverd = MAX(1,self.context.normalizedCommand.length / 4);
  self.mutableCommands = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSMutableArray __block *commandRanges = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSRegularExpression *commandRegExp = [[NSRegularExpression alloc] initWithPattern:@"\\{[^\\{\\}]+\\}" options:NSRegularExpressionCaseInsensitive error:0];
  NSAssert(commandRegExp, @"RegExp is constant. Has to work all the time");
  [commandRegExp enumerateMatchesInString:self.context.evaluatedCommand options:0 range:NSMakeRange(0, self.context.evaluatedCommand.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    @autoreleasepool {
      [commandRanges addObject:[NSValue valueWithRange:result.range]];
    }
  }];
  
  /* add range at the end as terminator */
  [commandRanges addObject:[NSValue valueWithRange:NSMakeRange(self.context.evaluatedCommand.length, 0)]];
  
  NSUInteger location = 0;
  CGEventFlags modifiers = 0;
  
  for(NSValue *rangeValue in commandRanges) {
    NSRange commandRange = rangeValue.rangeValue;
    /* All non-commands will get translated into key presses if possible, otherwiese into paste commands */
    if(location < commandRange.location) {
      /* If there were modifiers we need to use the next single stroke and update the modifier command */
      if(modifiers) {
        NSString *modifiedKey = [self.context.evaluatedCommand substringWithRange:NSMakeRange(location, 1)];
        MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifierMask:modifiers character:modifiedKey];
        if(press) {
          [self.mutableCommands addObject:press];
        }
        modifiers = 0;
        location++;
      }
      NSRange textRange = NSMakeRange(location, commandRange.location - location);
      if(textRange.length > 0) {
        NSString *textValue = [self.context.evaluatedCommand substringWithRange:textRange];
        [self _appendTextCommandWithContent:textValue];
      }
    }
    /* Test for modifer Key */
    NSString *commandString = [self.context.evaluatedCommand substringWithRange:commandRange];
    /* append commands for non-modifer keys */
    if(![self _updateModifierMask:&modifiers forCommand:commandString]) {
      [self _appendCommandForString:commandString activeModifer:modifiers];
      modifiers = 0; // Reset the modifers;
    }
    location = commandRange.location + commandRange.length;
  }
}

- (BOOL)_updateModifierMask:(CGEventFlags *)mask forCommand:(NSString *)commandString {
  NSAssert(mask != NULL, @"Input pointer missing!");
  if(mask == NULL) {
    return NO;
  }
  
  NSNumber *flagNumber = self.modifierCommands[commandString.uppercaseString];
  if(!flagNumber) {
    return NO; // No modifier key, just leave
  }
  CGEventFlags flags = flagNumber.eventFlagsValue;
  BOOL useCommandForControl = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeySendCommandForControlKey];
  if(useCommandForControl && flags == kCGEventFlagMaskControl) {
    flags = kCGEventFlagMaskCommand;
  }
  *mask |= flags;
  return YES;
}

- (void)_appendCommandForString:(NSString *)commandString activeModifer:(CGEventFlags)flags {
  if(!commandString || !commandString.length) {
    return;
  }
  /* Simple Special Press */
  NSString *uppercaseCommand = commandString.uppercaseString;
  NSNumber *keyCodeNumber = self.keypressCommands[uppercaseCommand];
  if(nil != keyCodeNumber) {
    MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(flags, keyCodeNumber.keyCodeValue)];
    if(press) {
      [self.mutableCommands addObject:press];
    }
    return; // Done
  }
  /* {PLUS}, {TILDE}, {PERCENT}, {+}, etc */
  NSString *character = self.characterCommands[uppercaseCommand];
  if(character) {
    MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifierMask:flags character:character];
    if(press) {
      [self.mutableCommands addObject:press];
    }
    return; // Done
  }
  
  /* F1-16 */
  static NSRegularExpression *functionKeyRegExp;
  static NSRegularExpression *numpadKeyRegExp;
  static NSRegularExpression *delayRegExp;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *delayPattern = [[NSString alloc] initWithFormat:@"\\{(%@|%@)([ |=])+([0-9]+)\\}",
                              kKPKAutotypeDelay,
                              kKPKAutotypeVirtualKey/*,
                                                     kKPKAutotypeVirtualExtendedKey,
                                                     kKPKAutotypeVirtualNonExtendedKey*/];
    functionKeyRegExp = [[NSRegularExpression alloc] initWithPattern:kKPKAutotypeFunctionMaskRegularExpression options:NSRegularExpressionCaseInsensitive error:0];
    numpadKeyRegExp = [[NSRegularExpression alloc] initWithPattern:kKPKAutotypeKeypaddNumberMaskRegularExpression options:NSRegularExpressionCaseInsensitive error:0];
    delayRegExp = [[NSRegularExpression alloc] initWithPattern:delayPattern options:NSRegularExpressionCaseInsensitive error:0];
  });
  NSTextCheckingResult *functionResult = [functionKeyRegExp firstMatchInString:commandString options:0 range:NSMakeRange(0, commandString.length)];
  if(functionResult && functionResult.numberOfRanges == 2) {
    NSString *numberString = [commandString substringWithRange:[functionResult rangeAtIndex:1]];
    NSScanner *numberScanner = [[NSScanner alloc] initWithString:numberString];
    NSInteger functionNumber = 0;
    if([numberScanner scanInteger:&functionNumber] && functionNumber >= 1 && functionNumber <= 19) {
      MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(flags, kMPFunctionKeyCodes[functionNumber-1])];
      if(press) {
        [self.mutableCommands addObject:press];
      }
      return; // Done
    }
  }
  
  /* Numpad0-9 */
  NSTextCheckingResult *numpadResult = [numpadKeyRegExp firstMatchInString:commandString options:0 range:NSMakeRange(0, commandString.length)];
  if(numpadResult && numpadResult.numberOfRanges == 2) {
    NSString *numberString = [commandString substringWithRange:[numpadResult rangeAtIndex:1]];
    NSScanner *numberScanner = [[NSScanner alloc] initWithString:numberString];
    NSInteger numpadNumber = 0;
    if([numberScanner scanInteger:&numpadNumber] && numpadNumber >= 0 && numpadNumber <= 9) {
      MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(flags, kMPNumpadKeyCodes[numpadNumber])];
      if(press) {
        [self.mutableCommands addObject:press];
      }
      return; // Done
    }
  }
  
  /* Clearfield */
  if([kKPKAutotypeClearField isEqualToString:uppercaseCommand]) {
    [self.mutableCommands addObject:[[MPAutotypeClear alloc] init]];
    return; // Done
  }
  // TODO: add {APPLICATION <appname>}
  /* Delay */
  NSTextCheckingResult *result = [delayRegExp firstMatchInString:commandString options:0 range:NSMakeRange(0, commandString.length)];
  if(result && (result.numberOfRanges == 4)) {
    NSString *uppercaseCommand = [[commandString substringWithRange:[result rangeAtIndex:1]] uppercaseString];
    NSString *assignOrNot = [commandString substringWithRange:[result rangeAtIndex:2]];
    NSString *valueString = [commandString substringWithRange:[result rangeAtIndex:3]];
    NSScanner *numberScanner = [[NSScanner alloc] initWithString:valueString];
    NSInteger value;
    if([numberScanner scanInteger:&value]) {
      if([kKPKAutotypeDelay isEqualToString:uppercaseCommand]) {
        if(MAX(0, value) <= 0) {
          return; // Value too low, just skipp
        }
        if([assignOrNot isEqualToString:@"="]) {
          [self.mutableCommands addObject:[[MPAutotypeDelay alloc] initWithGlobalDelay:value]];
        }
        else {
          [self.mutableCommands addObject:[[MPAutotypeDelay alloc] initWithDelay:value]];
        }
        return; // Done
      }
      else if([kKPKAutotypeVirtualKey isEqualToString:uppercaseCommand]) {
        NSLog(@"Virtual key strokes aren't supported yet!");
        // TODO add key
      }
    }
    else {
      NSLog(@"Unable to parse value part in command:%@", commandString);
    }
  }
  else {
    /* Fallback */
    [self _appendTextCommandWithContent:commandString];
  }
}

- (void)_appendTextCommandWithContent:(NSString *)content {
  if(content.length == 0) {
    return;
  }
  BOOL obfuscate = self.context.entry.autotype.obfuscateDataTransfer;
  if(obfuscate) {
    @autoreleasepool {
      /*
       * obfuscate entered data using Two-Channel Auto-Type Obfuscation
       * refer to KeePass documentation for more information
       * http://keepass.info/help/v2/autotype_obfuscation.html
       */
      
      NSMutableString *paste = [[NSMutableString alloc] initWithString:@""];
      //NSMutableArray<NSValue *> *typeKeys = [[NSMutableArray alloc] init];
      NSMutableArray<MPAutotypeCommand *> *typeCommands = [[NSMutableArray alloc] init];
      
      /*
       * seed the random number generator using the first 4 bytes of the string's SHA1
       * this ensures that you get the same string split every time for a given string
       */
      const char *cstr = [content cStringUsingEncoding:NSUTF8StringEncoding];
      NSData *data = [NSData dataWithBytes:cstr length:content.length];
      uint8_t digest[CC_SHA1_DIGEST_LENGTH];
      CC_SHA1(data.bytes, (unsigned int)data.length, digest);
      srandom(*((unsigned int*)digest));
      
      for(NSString *key in content.composedCharacters) {
        NSUInteger part = random() % 2;
        if (part == 0) {
          [paste appendString:key];
          [typeCommands addObject:[[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(0, kVK_RightArrow)]];
        }
        else {
          [typeCommands addObject:[[MPAutotypeKeyPress alloc] initWithModifierMask:0 character:key]];
        }
      }
      
      /* move to the end of the content */
      for (NSUInteger i = typeCommands.count; i < content.composedCharacterLength; i++) {
        [typeCommands addObject:[[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(0, kVK_RightArrow)]];
      }
      
      /* add paste command */
      MPAutotypePaste *pasteCommand = [[MPAutotypePaste alloc] initWithString:paste];
      [self.mutableCommands addObject:pasteCommand];
      
      /* add keypress commands */
      if(typeCommands.count > 0) {
        for(NSUInteger i = 0; i < paste.composedCharacterLength; i++) {
          MPAutotypeKeyPress *pressLeftArrowCommand = [[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(0, kVK_LeftArrow)];
          if(pressLeftArrowCommand) {
            [self.mutableCommands addObject:pressLeftArrowCommand];
          }
        }
        [self.mutableCommands addObjectsFromArray:typeCommands];
      }
    }
  }
  else {
    for(NSString *character in content.composedCharacters) {
      MPAutotypeKeyPress *keyPress = [[MPAutotypeKeyPress alloc] initWithModifierMask:0 character:character];
      if(keyPress) {
        [self.mutableCommands addObject:keyPress];
      }
    }
  }
}

@end

