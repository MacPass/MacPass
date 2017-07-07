//
//  MPModelChangeNotification.h
//  MacPass
//
//  Created by Michael Starke on 30/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPModelChangeObserving <NSObject>

@required
- (void)willChangeModelProperty;
- (void)didChangeModelProperty;

@end
