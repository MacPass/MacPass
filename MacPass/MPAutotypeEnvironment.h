//
//  MPAutotypeEnvironment.h
//  MacPass
//
//  Created by Michael Starke on 15.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KPKEntry;
@class MPAutotypeContext;

@interface MPAutotypeEnvironment : NSObject

/**
 The selected entry, if Autotype is run only for a single entry.
 If autotype should search for entries, set this to nil.
 */
@property (readonly, weak, nullable) KPKEntry *preferredEntry;
@property (readonly) pid_t pid; // the PID of the target application to which the key strokes should be sent
@property (readonly) CGWindowID windowId; // the windowID of the target window of the target application
@property (readonly, copy) NSString *windowTitle; /// The title of the target window of the target application.
@property (readonly) BOOL hidden; /// If set to YES, MacPass was hidden when autotype was initiated
@property (readonly) BOOL isSelfTargeting; /// If MacPass should autotype to itself, YES, otherwise NO
@property (readonly) NSString *overrideSequence; /// If set, this sequence is used for running the command regardless of the matched one

+ (instancetype)environmentWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry * _Nullable)entry overrideSequence:(NSString * _Nullable)overrideSequence;
- (instancetype)initWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry * _Nullable)entry overrideSequence:(NSString * _Nullable)overrdieSequence NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
