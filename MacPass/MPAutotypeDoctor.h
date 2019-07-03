//
//  MPAutotypeDoctor.h
//  MacPass
//
//  Created by Michael Starke on 03.07.19.
//  Copyright © 2019 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MPAutotypeIssue) {
  MPAutotypeIssueNoAccessibiltyPermission,
  MPAutotypeIssueNoScreenRecordingPermission  
};

@interface MPAutotypeDoctor : NSObject

@property (class, readonly, strong) MPAutotypeDoctor *defaultDoctor;

@property (nonatomic, readonly) BOOL hasAccessibiltyPermissions; // 10.14 requires accessibilty access to send key strokes to other applications
@property (nonatomic, readonly) BOOL hasScreenRecordingPermissions; // 10.15 requires screen recording permissions to get window names from other processes
@property (nonatomic, readonly, copy) NSString *localizedErrorDescription; // If any issues are present, this property holds alocalized error description

- (BOOL)checkPermissionsWithoutUserFeedback;
- (void)showPermissionCheckReport;

@end

NS_ASSUME_NONNULL_END
