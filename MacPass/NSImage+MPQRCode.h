//
//  NSImage+MPQRCode.h
//  MacPass
//
//  Created by Michael Starke on 10.12.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (MPQRCode)

@property (nonatomic, readonly, copy) NSString *QRCodeString;

@end

NS_ASSUME_NONNULL_END
