//
//  MPPickcharViewController.h
//  MacPass
//
//  Created by Michael Starke on 23.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
NS_ASSUME_NONNULL_BEGIN

@interface MPPickcharViewController : NSViewController

@property (copy) NSString *sourceValue;
@property (nonatomic, copy) NSString *pickedValue;
@property NSInteger countToPick;
@property (nonatomic) BOOL hideSource;

- (IBAction)reset:(id)sender;

@end

NS_ASSUME_NONNULL_END
