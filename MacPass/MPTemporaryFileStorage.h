//
//  MPTemporaryFileStorage.h
//  MacPass
//
//  Created by Michael Starke on 18/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@class KPKBinary;
/**
 *  File Storage the Storage center vents on request. Use this to feed as datasource to QLPreviewPanels
 */
@interface MPTemporaryFileStorage : NSObject <QLPreviewPanelDataSource, QLPreviewItem>

- (instancetype)initWithBinary:(KPKBinary *)binary;

- (void)cleanup;
- (void)cleanupNow;

@end