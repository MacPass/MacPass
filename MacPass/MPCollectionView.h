//
//  MPCollectionView.h
//  MacPass
//
//  Created by Michael Starke on 18.09.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPCollectionView : NSCollectionView

@property NSUInteger contextMenuIndex; // the index the context menu was last opened. NSNotFound if invalid

@end
