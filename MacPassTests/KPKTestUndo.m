//
//  KPKUndo.m
//  MacPass
//
//  Created by Michael Starke on 04/08/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "KPKTree.h"
#import "KPKGroup.h"
#import "KPKEntry.h"

@interface KPKTestUndo : XCTestCase <KPKTreeDelegate> {
  NSUndoManager *_undoManager;
  KPKTree *_tree;
  KPKGroup *_groupA, *_groupB;
  KPKEntry *_entryA, *_entryB;
}
@end

@implementation KPKTestUndo

- (NSUndoManager *)undoManagerForTree:(KPKTree *)tree {
  return _undoManager;
}

- (void)setUp {
  [super setUp];
  _undoManager = [[NSUndoManager alloc] init];
  _tree = [[KPKTree alloc] init];
  _tree.delegate = self;
  
  _groupA = [[KPKGroup alloc] init];
  _groupB = [[KPKGroup alloc] init];
  _entryA = [[KPKEntry alloc] init];
  _entryB = [[KPKEntry alloc] init];
  
  [_undoManager disableUndoRegistration];
  [_undoManager enableUndoRegistration];
}

- (void)tearDown {
  _undoManager = nil;
  [super tearDown];
}

- (void)testUndoRedoCreateEntry {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoCreateGroup {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoCopyEntry {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoCopyGroup {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoMoveEntry {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoMoveGroup {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoDeleteGroupWithoutTrash {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoDeleteEntryWithoutTrash {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoDeleteGroupWithTrash {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoDeleteEntryWithTrash {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoEditEntry {
  XCTFail(@"Missing Test");
}

- (void)testUndoRedoEditGroup {
  XCTFail(@"Missing Test");
}



@end
