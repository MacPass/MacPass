//
//  MPCustomFieldTableDelegate.h
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPInspectorViewController;

@interface MPCustomFieldTableViewDelegate : NSObject <NSTableViewDelegate>

@property (weak, nonatomic) id viewController;

@end
