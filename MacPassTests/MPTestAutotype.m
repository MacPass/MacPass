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
  self.entry.username = @"Username";
  self.entry.password = @"Password";
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
  XCTAssertEqual(commands.count, 1);
  MPAutotypePaste *paste = commands[0];
  NSString *result = [[NSString alloc] initWithFormat:@"%@%@%@%@", numberAttribute.value, self.entry.username, self.entry.username, self.entry.username];
  XCTAssertEqualObjects(paste.pasteData, result);
}

- (void)testFunctionKeyCommand {
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"{F0}{F1}{F2}{F3}{F4}{F5}^%{F6}{F7}{F19}{F20}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  XCTAssertEqual(commands.count, 10);
  /* {F0} -> invalid, paste */
  MPAutotypePaste *paste = commands[0];
  XCTAssertEqualObjects(paste.pasteData, @"{F0}");
  
  /* {F1} */
  MPAutotypeKeyPress *key = commands[1];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F1);
  
  /* {F2} */
  key = commands[2];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F2);
  
  /* {F3} */
  key = commands[3];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F3);
  
  /* {F4} */
  key = commands[4];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F4);
  
  /* {F5} */
  key = commands[5];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F5);
  
  /* ^%{F6} */
  key = commands[6];
  XCTAssertEqual(key.key.modifier, (kCGEventFlagMaskCommand | kCGEventFlagMaskAlternate));
  XCTAssertEqual(key.key.keyCode, kVK_F6);
  
  /* {F7} */
  key = commands[7];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F7);
  
  /* {F19} */
  key = commands[8];
  XCTAssertEqual(key.key.modifier, 0);
  XCTAssertEqual(key.key.keyCode, kVK_F19);
  
  paste = commands[9];
  XCTAssertEqualObjects(paste.pasteData, @"{F20}");
}

- (void)testCommandCreation {
  /* Command 1 */
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"{USERNAME}{TAB}{PASSWORD}{ENTER}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  
  XCTAssertEqual(commands.count, 4);
  XCTAssertTrue([commands[0] isKindOfClass:[MPAutotypePaste class]]);
  XCTAssertTrue([commands[1] isKindOfClass:[MPAutotypeKeyPress class]]);
  XCTAssertTrue([commands[2] isKindOfClass:[MPAutotypePaste class]]);
  XCTAssertTrue([commands[3] isKindOfClass:[MPAutotypeKeyPress class]]);
  
  /* {USERNAME} */
  MPAutotypePaste *paste = commands[0];
  XCTAssertEqualObjects(paste.pasteData, self.entry.username);
  
  /* {TAB} */
  MPAutotypeKeyPress *keyPress = commands[1];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Tab); // Tab is a fixed key, no mapping needed
  XCTAssertEqual(keyPress.key.modifier, 0);
  
  /* {PASSWORD} */
  paste = commands[2];
  XCTAssertEqualObjects(self.entry.password, paste.pasteData);
  
  /* {ENTER} */
  keyPress = commands[3];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Return);
  
  /* Command 2 */
  context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"^T{USERNAME}%+^{TAB}Whoo{PASSWORD}{ENTER}"];
  commands = [MPAutotypeCommand commandsForContext:context];
  XCTAssertEqual(commands.count, 5);
  XCTAssertTrue([commands[0] isKindOfClass:[MPAutotypeKeyPress class]]);
  XCTAssertTrue([commands[1] isKindOfClass:[MPAutotypePaste class]]);
  XCTAssertTrue([commands[2] isKindOfClass:[MPAutotypeKeyPress class]]);
  XCTAssertTrue([commands[3] isKindOfClass:[MPAutotypePaste class]]);
  XCTAssertTrue([commands[4] isKindOfClass:[MPAutotypeKeyPress class]]);
  
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
  
  /* {USERNAME} */
  paste = commands[1];
  XCTAssertEqualObjects(paste.pasteData, self.entry.username);
  
  /* %+^{TAB} */
  keyPress = commands[2];
  XCTAssertEqual(keyPress.key.keyCode, kVK_Tab); // Tab is a fixed key, no mapping needed
  if(useCommandInsteadOfControl) {
    XCTAssertEqual(keyPress.key.modifier, (kCGEventFlagMaskCommand | kCGEventFlagMaskShift | kCGEventFlagMaskAlternate));
  }
  else {
    XCTAssertEqual(keyPress.key.modifier, (kCGEventFlagMaskControl | kCGEventFlagMaskShift | kCGEventFlagMaskAlternate));
  }
  
  /* Whoo{PASSWORD} */
  paste = commands[3];
  NSString *pasteString = [[NSString alloc] initWithFormat:@"%@%@", @"Whoo", self.entry.password];
  XCTAssertEqualObjects(pasteString, paste.pasteData);
  
  /* {ENTER} */
  keyPress = commands[4];
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
