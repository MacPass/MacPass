//
//  MPTestAutotype.m
//  MacPass
//
//  Created by Michael Starke on 07/08/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <XCTest/XCTest.h>
#import <KeePassKit/KeePassKit.h>

#import "MPAutotypeCommand.h"
#import "MPAutotypeContext.h"
#import "MPAutotypePaste.h"
#import "MPAutotypeKeyPress.h"

#import "MPSettingsHelper.h"

#import "MPKeyMapper.h"


@interface MPTestAutotype : XCTestCase
@property (strong) KPKEntry *entry;
@end

@implementation MPTestAutotype

- (void)setUp {
  [super setUp];
  self.entry = [[KPKEntry alloc] init];
  self.entry.title = @"Title";
  self.entry.url = @"www.myurl.com";
  self.entry.username = @"User Name";
  self.entry.password = @"Pass👩🏿‍🔧word";
}

- (void)tearDown {
  self.entry = nil;
  [super tearDown];
}

- (void)testCaseInsenstivieKeyPress {
  /* Command 1 */
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"{TAB}{ENTER}~{tAb}{ShIfT}{enter}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  
  XCTAssertTrue(commands.count == 5);
  /* {TAB} */
  MPAutotypeKeyPress *keyPress = commands[0];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Tab);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* {ENTER} */
  keyPress = commands[1];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Return);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* ~ -> Enter */
  keyPress = commands[2];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Return);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* {tAb} */
  keyPress = commands[3];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Tab);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* {ShIfT}{enter}*/
  keyPress = commands[4];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Return);
  XCTAssertEqual(keyPress.key.modifier, kCGEventFlagMaskShift);
}

- (void)testCaseSensitiveCustomAttributeLookup {
  KPKAttribute *lowerCaseAttribute = [[KPKAttribute alloc] initWithKey:@"custom" value:@"value"];
  KPKAttribute *upperCaseAttribute = [[KPKAttribute alloc] initWithKey:@"CUSTOM" value:@"VALUE"];
  KPKAttribute *mixedCaseAttribute = [[KPKAttribute alloc] initWithKey:@"CuStOm" value:@"VaLuE"];
  KPKAttribute *randomCase = [[KPKAttribute alloc] initWithKey:@"custoM" value:@"valuE"];
  [self.entry addCustomAttribute:lowerCaseAttribute];
  [self.entry addCustomAttribute:upperCaseAttribute];
  [self.entry addCustomAttribute:mixedCaseAttribute];
  [self.entry addCustomAttribute:randomCase];
  
  self.entry.autotype.defaultKeystrokeSequence = [[NSString alloc] initWithFormat:@"{USERNAME}{s:%@}{S:%@}{s:%@}", lowerCaseAttribute.key, mixedCaseAttribute.key, upperCaseAttribute.key];
  
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithDefaultSequenceForEntry:self.entry];
  NSString *result = [[NSString alloc] initWithFormat:@"%@%@%@%@", self.entry.username, lowerCaseAttribute.value, mixedCaseAttribute.value, upperCaseAttribute.value];
  XCTAssertEqualObjects(context.evaluatedCommand, result);
}

- (void)testCustomAttributeRepetition {
  KPKAttribute *numberAttribute = [[KPKAttribute alloc] initWithKey:@"NoRepeat 3" value:@"NoRepeatValue"];
  [self.entry addCustomAttribute:numberAttribute];
  
  NSString *autotypeSequence = [[NSString alloc] initWithFormat:@"{S:%@}{USERNAME 3}", numberAttribute.key];
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:autotypeSequence];
  
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  
  /* NoRepeatValueUsernameUsernameUsername */
  XCTAssertEqual(commands.count, 40);
  MPAutotypeKeyPress *keyPress = commands.firstObject;
  XCTAssertEqualObjects(keyPress.character, @"N");
  keyPress = commands[1];
  XCTAssertEqualObjects(keyPress.character, @"o");
  keyPress = commands[2];
  XCTAssertEqualObjects(keyPress.character, @"R");
  keyPress = commands[3];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[4];
  XCTAssertEqualObjects(keyPress.character, @"p");
  keyPress = commands[5];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[6];
  XCTAssertEqualObjects(keyPress.character, @"a");
  keyPress = commands[7];
  XCTAssertEqualObjects(keyPress.character, @"t");
  keyPress = commands[8];
  XCTAssertEqualObjects(keyPress.character, @"V");
  keyPress = commands[9];
  XCTAssertEqualObjects(keyPress.character, @"a");
  keyPress = commands[10];
  XCTAssertEqualObjects(keyPress.character, @"l");
  keyPress = commands[11];
  XCTAssertEqualObjects(keyPress.character, @"u");
  keyPress = commands[12];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[13];
  XCTAssertEqualObjects(keyPress.character, @"U");
  keyPress = commands[14];
  XCTAssertEqualObjects(keyPress.character, @"s");
  keyPress = commands[15];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[16];
  XCTAssertEqualObjects(keyPress.character, @"r");
  keyPress = commands[17];
  XCTAssertEqualObjects(keyPress.character, @" ");
  keyPress = commands[18];
  XCTAssertEqualObjects(keyPress.character, @"N");
  keyPress = commands[19];
  XCTAssertEqualObjects(keyPress.character, @"a");
  keyPress = commands[20];
  XCTAssertEqualObjects(keyPress.character, @"m");
  keyPress = commands[21];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[22];
  XCTAssertEqualObjects(keyPress.character, @"U");
  keyPress = commands[23];
  XCTAssertEqualObjects(keyPress.character, @"s");
  keyPress = commands[24];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[25];
  XCTAssertEqualObjects(keyPress.character, @"r");
  keyPress = commands[26];
  XCTAssertEqualObjects(keyPress.character, @" ");
  keyPress = commands[27];
  XCTAssertEqualObjects(keyPress.character, @"N");
  keyPress = commands[28];
  XCTAssertEqualObjects(keyPress.character, @"a");
  keyPress = commands[29];
  XCTAssertEqualObjects(keyPress.character, @"m");
  keyPress = commands[30];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[31];
  XCTAssertEqualObjects(keyPress.character, @"U");
  keyPress = commands[32];
  XCTAssertEqualObjects(keyPress.character, @"s");
  keyPress = commands[33];
  XCTAssertEqualObjects(keyPress.character, @"e");
  keyPress = commands[34];
  XCTAssertEqualObjects(keyPress.character, @"r");
  keyPress = commands[35];
  XCTAssertEqualObjects(keyPress.character, @" ");
  keyPress = commands[36];
  XCTAssertEqualObjects(keyPress.character, @"N");
  keyPress = commands[37];
  XCTAssertEqualObjects(keyPress.character, @"a");
  keyPress = commands[38];
  XCTAssertEqualObjects(keyPress.character, @"m");
  keyPress = commands[39];
  XCTAssertEqualObjects(keyPress.character, @"e");
}

- (void)testFunctionKeyCommand {
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"{F0}{F1}{F2}{F3}{F4}{F5}^%{F6}{F7}{F19}{F20}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  XCTAssertEqual(commands.count, 17);
  /* {F0} -> invalid, type */
  MPAutotypeKeyPress *key = commands[0];
  XCTAssertEqualObjects(key.character, @"{");
  key = commands[1];
  XCTAssertEqualObjects(key.character, @"F");
  key = commands[2];
  XCTAssertEqualObjects(key.character, @"0");
  key = commands[3];
  XCTAssertEqualObjects(key.character, @"}");
  
  /* {F1} */
  key = commands[4];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F1);
  
  /* {F2} */
  key = commands[5];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F2);
  
  /* {F3} */
  key = commands[6];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F3);
  
  /* {F4} */
  key = commands[7];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F4);
  
  /* {F5} */
  key = commands[8];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F5);
  
  /* ^%{F6} */
  key = commands[9];
  XCTAssertEqual(key.key.modifier, (kCGEventFlagMaskCommand | kCGEventFlagMaskAlternate));
  XCTAssertEqual(key.key.keyCode, kVK_F6);
  
  /* {F7} */
  key = commands[10];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F7);
  
  /* {F19} */
  key = commands[11];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F19);
  
  /* {F20} -> invalid, type */
  key = commands[12];
  XCTAssertEqualObjects(key.character, @"{");

  key = commands[13];
  XCTAssertEqualObjects(key.character, @"F");

  key = commands[14];
  XCTAssertEqualObjects(key.character, @"2");

  key = commands[15];
  XCTAssertEqualObjects(key.character, @"0");

  key = commands[16];
  XCTAssertEqualObjects(key.character, @"}");

}

- (void)testCommandCreation {
  /* Command 1 */
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"{USERNAME}{TAB}{PASSWORD}{ENTER}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  
  XCTAssertEqual(commands.count, 20);
  
  /* {USERNAME} -> type U s e r   N a m e*/
  MPAutotypeKeyPress *keyPress = commands[0];
  XCTAssertEqualObjects(keyPress.character, @"U");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[1];
  XCTAssertEqualObjects(keyPress.character, @"s");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[2];
  XCTAssertEqualObjects(keyPress.character, @"e");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[3];
  XCTAssertEqualObjects(keyPress.character, @"r");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[4];
  XCTAssertEqualObjects(keyPress.character, @" ");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[5];
  XCTAssertEqualObjects(keyPress.character, @"N");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[6];
  XCTAssertEqualObjects(keyPress.character, @"a");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[7];
  XCTAssertEqualObjects(keyPress.character, @"m");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[8];
  XCTAssertEqualObjects(keyPress.character, @"e");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* {TAB} */
  keyPress = commands[9];
  XCTAssertNil(keyPress.character);
  XCTAssertEqual(keyPress.key.keyCode, kVK_Tab); // Tab is a fixed key, no mapping needed
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* {PASSWORD} -> type P a s s 👩🏿‍🔧 w o r d */
  keyPress = commands[10];
  XCTAssertEqualObjects(keyPress.character, @"P");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[11];
  XCTAssertEqualObjects(keyPress.character, @"a");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[12];
  XCTAssertEqualObjects(keyPress.character, @"s");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[13];
  XCTAssertEqualObjects(keyPress.character, @"s");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[14];
  XCTAssertEqualObjects(keyPress.character, @"👩🏿‍🔧");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[15];
  XCTAssertEqualObjects(keyPress.character, @"w");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[16];
  XCTAssertEqualObjects(keyPress.character, @"o");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[17];
  XCTAssertEqualObjects(keyPress.character, @"r");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[18];
  XCTAssertEqualObjects(keyPress.character, @"d");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  
  /* {ENTER} */
  keyPress = commands[19];
  XCTAssertNil(keyPress.character);
  XCTAssertEqual(keyPress.key.keyCode, kVK_Return);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* Command 2 */
  context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"^T{USERNAME}%+^{TAB}Whoo{PASSWORD}{ENTER}"];
  commands = [MPAutotypeCommand commandsForContext:context];
  XCTAssertEqual(commands.count, 25);
  
  /* ^T */
  keyPress = commands[0];
  /* lowercase T since we supplied modifiers so the ones needed for Uppercase T will be ignored, instead the "t" key is used */
  XCTAssertEqualObjects(@"t", [MPKeyMapper stringForModifiedKey:keyPress.key]);
  BOOL useCommandInsteadOfControl = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeySendCommandForControlKey];
  if(useCommandInsteadOfControl) {
    XCTAssertEqual(keyPress.key.modifier, kCGEventFlagMaskCommand);
  }
  else {
      XCTAssertEqual(keyPress.key.modifier, kCGEventFlagMaskControl);
  }
  
  /* {USERNAME} -> type U s e r   N a m e */
  keyPress = commands[1];
  XCTAssertEqualObjects(keyPress.character, @"U");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[2];
  XCTAssertEqualObjects(keyPress.character, @"s");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[3];
  XCTAssertEqualObjects(keyPress.character, @"e");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[4];
  XCTAssertEqualObjects(keyPress.character, @"r");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[5];
  XCTAssertEqualObjects(keyPress.character, @" ");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[6];
  XCTAssertEqualObjects(keyPress.character, @"N");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[7];
  XCTAssertEqualObjects(keyPress.character, @"a");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[8];
  XCTAssertEqualObjects(keyPress.character, @"m");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[9];
  XCTAssertEqualObjects(keyPress.character, @"e");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* %+^{TAB} */
  keyPress = commands[10];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Tab); // Tab is a fixed key, no mapping needed
  if(useCommandInsteadOfControl) {
    XCTAssertEqual(keyPress.key.modifier, (kCGEventFlagMaskCommand | kCGEventFlagMaskShift | kCGEventFlagMaskAlternate));
  }
  else {
    XCTAssertEqual(keyPress.key.modifier, (kCGEventFlagMaskControl | kCGEventFlagMaskShift | kCGEventFlagMaskAlternate));
  }
  
  /* Whoo{PASSWORD} -> type W h o o P a s s w o r d */
  keyPress = commands[11];
  XCTAssertEqualObjects(keyPress.character, @"W");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[12];
  XCTAssertEqualObjects(keyPress.character, @"h");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[13];
  XCTAssertEqualObjects(keyPress.character, @"o");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);

  keyPress = commands[14];
  XCTAssertEqualObjects(keyPress.character, @"o");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[15];
  XCTAssertEqualObjects(keyPress.character, @"P");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[16];
  XCTAssertEqualObjects(keyPress.character, @"a");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[17];
  XCTAssertEqualObjects(keyPress.character, @"s");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[18];
  XCTAssertEqualObjects(keyPress.character, @"s");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[19];
  XCTAssertEqualObjects(keyPress.character, @"👩🏿‍🔧");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[20];
  XCTAssertEqualObjects(keyPress.character, @"w");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[21];
  XCTAssertEqualObjects(keyPress.character, @"o");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[22];
  XCTAssertEqualObjects(keyPress.character, @"r");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  keyPress = commands[23];
  XCTAssertEqualObjects(keyPress.character, @"d");
  XCTAssertEqual(keyPress.key.keyCode, 0);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* {ENTER} */
  keyPress = commands[24];
  XCTAssertNil(keyPress.character);
  XCTAssertEqual(keyPress.key.keyCode, kVK_Return);
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  
  /* Command 3 */
  context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"^T"];
  commands = [MPAutotypeCommand commandsForContext:context];
  XCTAssertEqual(commands.count, 1);
  XCTAssertTrue([commands.firstObject isKindOfClass:[MPAutotypeKeyPress class]]);
  
  /*^T*/
  keyPress = commands.firstObject;
  XCTAssertEqualObjects(@"t", [MPKeyMapper stringForModifiedKey:keyPress.key]);
  
  if(useCommandInsteadOfControl) {
    XCTAssertEqual(keyPress.key.modifier, kCGEventFlagMaskCommand);
  }
  else {
    XCTAssertEqual(keyPress.key.modifier, kCGEventFlagMaskControl);
  }
  
}


@end
