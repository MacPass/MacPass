//
//  MPAutotypeParser.h
//  MacPass
//
//  Created by Michael Starke on 02.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPAutotypeCommand;
@class MPAutotypeContext;

@interface MPAutotypeParser : NSObject

@property (nonatomic, copy, readonly) NSArray<MPAutotypeCommand *> *commands;
@property (readonly, strong) MPAutotypeContext *context;

- (instancetype)initWithContext:(MPAutotypeContext *)context;

@end

NS_ASSUME_NONNULL_END
