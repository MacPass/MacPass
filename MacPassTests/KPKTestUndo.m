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
  KPKGroup *_root, *_groupA, *_groupB;
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
  
  /* Disable undo registration in the setup to have a clean test environment */
  [_undoManager disableUndoRegistration];
  
  _root = [[KPKGroup alloc] init];
  
  _tree.root = _root;
  
  _groupA = [[KPKGroup alloc] init];
  _groupA.title = @"Group A";
  _groupB = [[KPKGroup alloc] init];
  _groupB.title = @"Group B";
  
  [_root addGroup:_groupA];
  [_root addGroup:_groupB];
  
  _entryA = [[KPKEntry alloc] init];
  _entryA.title = @"Entry A";
  _entryA.username = @"Username A";
  _entryA.url = @"http://www.a.com";
  
  [_groupA addEntry:_entryA];
  
  _entryB = [[KPKEntry alloc] init];
  _entryB.title = @"Entry B";
  _entryB.username = @"Username B";
  _entryB.url = @"http://www.b.com";
  
  [_groupB addEntry:_entryB];
  
  /* Enable undo registration for the tests */
  [_undoManager enableUndoRegistration];
}

- (void)tearDown {
  _entryA = nil;
  _entryB = nil;
  _groupB = nil;
  _groupA = nil;
  _tree = nil;
  _undoManager = nil;
  [super tearDown];
}

- (void)testUndoRedoCreateEntry {
  
  XCTAssertFalse(_undoManager.canUndo, @"Undo stack is empty");
  XCTAssertFalse(_undoManager.canRedo, @"Redo stack is empty");
  KPKEntry *entry = [_tree createEntry:_groupA];
  [_groupA addEntry:entry];
  
  
  XCTAssertEqual(_groupA.entries.count, 2, @"Group A has two entries");
  XCTAssertTrue([_groupA.entries containsObject:entry], @"Created entry is in group A");
  
  XCTAssertEqual(_groupB.entries.count, 1, @"Group B has one entry");
  XCTAssertFalse([_groupB.entries containsObject:entry], @"Created entry is not in group B");
  
  XCTAssertEqual(_root.entries.count, 0, @"Root has no entries");
  XCTAssertFalse([_root.entries containsObject:entry], @"Created entry is not in root group");
  
  XCTAssertTrue(_undoManager.canUndo, @"Undomanager can undo");
  
  [_undoManager undo];
  
  XCTAssertEqual(_groupA.entries.count, 1, @"Group A has one entry after undo");
  XCTAssertFalse([_groupA.entries containsObject:entry], @"Created enty is not in group A");
  
  XCTAssertEqual(_groupB.entries.count, 1, @"Group B has one entry");
  XCTAssertFalse([_groupB.entries containsObject:entry], @"Created enty is not in group A");
  
  XCTAssertEqual(_root.entries.count, 0, @"Root has no entries");
  XCTAssertFalse([_root.entries containsObject:entry], @"Created enty is not in group A");
  
  XCTAssertFalse(_undoManager.canUndo, @"Undomanager cannot undo anymore");
  XCTAssertTrue(_undoManager.canRedo, @"Undomanger can redo executed undo");
  
  [_undoManager redo];
  
  XCTAssertEqual(_groupA.entries.count, 2, @"Group A has two entries");
  XCTAssertTrue([_groupA.entries containsObject:entry], @"Created entry is in group A");
  
  XCTAssertEqual(_groupB.entries.count, 1, @"Group B has one entry");
  XCTAssertFalse([_groupB.entries containsObject:entry], @"Created entry is not in group B");
  
  XCTAssertEqual(_root.entries.count, 0, @"Root has no entries");
  XCTAssertFalse([_root.entries containsObject:entry], @"Created entry is not in root group");
}

- (void)testUndoRedoCreateGroup {
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
