//
//  MPAutotypeDoctor.h
//  MacPass
//
//  Created by Michael Starke on 03.07.19.
//  Copyright © 2019 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPAutotypeDoctor : NSObject

typedef NS_ENUM(NSUInteger, MPAutotypeTask) {
  MPAutotypeTaskAutotype,
  MPAutotypeTaskGlobalAutotype
};

@property (class, readonly, strong) MPAutotypeDoctor *defaultDoctor;

- (BOOL)hasNecessaryPermissionForTask:(MPAutotypeTask)task;
- (BOOL)hasScreenRecordingPermissions:(NSError *__autoreleasing*)error;
- (BOOL)hasAccessibiltyPermissions:(NSError *__autoreleasing*)error;

- (void)runChecksAndPresentResults;
- (void)openScreenRecordingPreferences;
- (void)requestScreenRecordingPermission;
- (void)openAccessibiltyPreferences;
- (void)openAutomationPreferences;

@end

NS_ASSUME_NONNULL_END
