//
//  MPPastBoardController.h
//  MacPass
//
//  Created by Michael Starke on 02.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPPasteBoardController : NSObject

/*
 This time sets the time interval after which a copied entry shoudl be purged from the pasteboard
 */
@property (assign, nonatomic) NSTimeInterval clearTimeout;
@property (assign, nonatomic) BOOL clearPasteboardOnShutdown;

+ (MPPasteBoardController *)defaultController;

- (void)copyObjects:(NSArray *)objects;

@end
