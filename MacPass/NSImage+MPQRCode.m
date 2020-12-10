//
//  NSImage+MPQRCode.m
//  MacPass
//
//  Created by Michael Starke on 10.12.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "NSImage+MPQRCode.h"
#import <CoreImage/CoreImage.h>

@implementation NSImage (MPQRCode)

- (NSString *)QRCodeString {
  NSRect rect = NSMakeRect(0, 0, self.size.width, self.size.height);
  NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)[self bestRepresentationForRect:rect context:nil hints:nil];
  CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmapRep];
  CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
  NSArray<CIFeature *> *features = [detector featuresInImage:ciImage];
  for(CIFeature *feature in features) {
    if(feature.type == CIFeatureTypeQRCode) {
      CIQRCodeFeature *qrCodeFeature = (CIQRCodeFeature *)feature;
      return qrCodeFeature.messageString;
    }
  }
  return @"";
}

@end
