//
//  KPKTestAutotypeNormalization.m
//  MacPass
//
//  Created by Michael Starke on 18.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Commands.h"
#import "MPAutotypeCommand.h"
#import "MPAutotypeContext.h"

#import "KPKEntry.h"

@interface KPKTestAutotypeNormalization : XCTestCase

@end

@implementation KPKTestAutotypeNormalization

- (void)testSimpleNormalization {
  NSString *normalized = [@"Whoo %{%}{^}{SHIFT}+ {SPACE}{ENTER}^V%V~T" normalizedAutotypeSequence];
  XCTAssertTrue([normalized isEqualToString:@"Whoo{SPACE}{ALT}{%}{^}{SHIFT}{SHIFT}{SPACE}{SPACE}{ENTER}{CONTROL}V{ALT}V{ENTER}T"]);
}

- (void)testCommandRepetition {
  NSString *normalized = [@"Whoo %{% 2}{^}{SHIFT 5}+ {SPACE}{ENTER}^V%V~T" normalizedAutotypeSequence];
  XCTAssertTrue([normalized isEqualToString:@"Whoo{SPACE}{ALT}{%}{%}{^}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SPACE}{SPACE}{ENTER}{CONTROL}V{ALT}V{ENTER}T"]);
  normalized = [@"{TAB 5}TAB{TAB}{SHIFT}{SHIFT 10}ENTER{ENTER}{%%}" normalizedAutotypeSequence];
  XCTAssertTrue([normalized isEqualToString:@"{TAB}{TAB}{TAB}{TAB}{TAB}TAB{TAB}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}ENTER{ENTER}{%%}"]);
}

- (void)testeBracketValidation {
  XCTAssertFalse([@"{BOOO}NO-COMMAND{TAB}{WHOO}{WHOO}{SPACE}!!!thisIsFun{{MISMATCH!!!}" validateCommmand]);
  XCTAssertFalse([@"{{}}}}" validateCommmand]);
  XCTAssertFalse([@"{}{}{{{}{{{{{{}}" validateCommmand]); 
  XCTAssertTrue([@"{}{}{}{}{}{      }ThisIsValid{}{STOP}" validateCommmand]);
}

- (void)testCommandCreation {
  KPKEntry *entry = [[KPKEntry alloc] init];
  entry.title = @"Title";
  entry.url = @"www.myurl.com";
  entry.username = @"Username";
  entry.password = @"Password";
  
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:entry andSequence:@"{USERNAME}{TAB}{PASSWORD}{ENTER}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
}
@end
