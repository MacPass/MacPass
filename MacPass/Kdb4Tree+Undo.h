//
//  Kdb4Tree+Undo.h
//  MacPass
//
//  Created by Michael Starke on 27.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Node.h"

APPKIT_EXTERN NSString *const MPTree4DatabaseNameUndoableKey;
APPKIT_EXTERN NSString *const MPTree4DatabaseDescriptionUndoableKey;
APPKIT_EXTERN NSString *const MPTree4DatabaseDefaultUsernameUndoableKey;

APPKIT_EXTERN NSString *const MPTree4ProtectNotesUndoableKey;
APPKIT_EXTERN NSString *const MPTree4ProtectPasswordUndoableKey;
APPKIT_EXTERN NSString *const MPTree4ProtectTitleUndoableKey;
APPKIT_EXTERN NSString *const MPTree4ProtectUrlUndoableKey;
APPKIT_EXTERN NSString *const MPTree4ProtectUsernameUndoableKey;

@interface Kdb4Tree (Undo)

- (NSString *)databaseNameUndoable;
- (NSString *)databaseDescriptionUndoable;
- (NSString *)defaultUserNameUndoable;

- (void)setDatabaseDescriptionUndoable:(NSString *)databaseDescription;
- (void)setDatabaseNameUndoable:(NSString *)databaseName;
- (void)setDefaultUserNameUndoable:(NSString *)defaultUserName;

- (BOOL)protectNotesUndoable;
- (BOOL)protectPasswordUndoable;
- (BOOL)protectTitleUndoable;
- (BOOL)protectUrlUndoable;
- (BOOL)protectUserNameUndoable;

- (void)setProtectNotesUndoable:(BOOL)protectNotes;
- (void)setProtectPasswordUndoable:(BOOL)protectPassword;
- (void)setProtectTitleUndoable:(BOOL)protectTitle;
- (void)setProtectUrlUndoable:(BOOL)protectUrl;
- (void)setProtectUserNameUndoable:(BOOL)protectUserName;


//@property(nonatomic, assign) NSInteger maintenanceHistoryDays;
//
//@property(nonatomic, retain) NSDate *masterKeyChanged;
//@property(nonatomic, assign) NSInteger masterKeyChangeRec;
//@property(nonatomic, assign) NSInteger masterKeyChangeForce;
//
//@property(nonatomic, assign) BOOL recycleBinEnabled;
//@property(nonatomic, retain) NSDate *recycleBinChanged;
//
//@property(nonatomic, assign) NSInteger historyMaxItems;
//@property(nonatomic, assign) NSInteger historyMaxSize;
//
//@property(nonatomic, readonly) NSMutableArray *binaries;

@end
