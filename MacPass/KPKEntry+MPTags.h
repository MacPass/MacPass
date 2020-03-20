//
//  KPKEntry+MPTags.h
//  MacPass
//
//  Created by Michael Starke on 20.03.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <KeePassKit/KeePassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KPKEntry (MPTags)

@property (readonly, copy) NSString *tagsString;

@end

NS_ASSUME_NONNULL_END
