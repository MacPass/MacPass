//
//  MPDocument+ModelChange.m
//  MacPass
//
//  Created by Michael Starke on 30/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

NSString *const MPDocumentWillChangeModelPropertyNotification = @"com.hicknhack.macpass.MPDocumentWillChangeModelPropertyNotification";
NSString *const MPDocumentDidChangeModelPropertyNotification  = @"com.hicknhack.macpass.MPDocumentDidChangeModelPropertyNotification";

@implementation MPDocument (ModelChange)

- (void)willChangeModelProperty {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentWillChangeModelPropertyNotification object:self];
}

- (void)didChangeModelProperty {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidChangeModelPropertyNotification object:self];
}

@end
