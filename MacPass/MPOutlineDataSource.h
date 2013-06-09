//
//  MPOutlineDataSource.h
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KdbGroup;

@interface MPOutlineDataSource : NSObject <NSOutlineViewDataSource> {
  KdbGroup *_draggedItem;
}
@end
