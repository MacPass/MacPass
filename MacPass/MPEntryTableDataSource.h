//
//  MPEntyTableDataSource.h
//  MacPass
//
//  Created by Michael Starke on 09.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPEntryViewController;
@interface MPEntryTableDataSource : NSObject <NSTableViewDataSource>

@property (assign, nonatomic) MPEntryViewController *viewController;

@end
