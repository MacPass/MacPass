//
//  KPKIconLoading.m
//  MacPass
//
//  Created by Michael Starke on 20.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKIconLoading.h"
#import "KPKIcon.h"

@implementation KPKIconLoading

- (void)setUp {
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  _image = [myBundle imageForResource:@"image.png"];
  _imageData = [[[_image representations] lastObject] representationUsingType:NSPNGFileType properties:nil];
}

- (void)tearDown {
  _image = nil;
  _imageData = nil;
}

- (void)testLoading {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *imageURL = [myBundle URLForImageResource:@"image.png"];
  KPKIcon *icon = [[KPKIcon alloc] initWithImageAtURL:imageURL];
  STAssertNotNil(icon, @"Icon should have been loaded");
  NSString *iconString = [icon encodedString];
  KPKIcon *iconFromString = [[KPKIcon alloc] initWithUUID:[NSUUID UUID] encodedString:iconString];
  STAssertTrue([iconString isEqualToString:[iconFromString encodedString]], @"Encoding and Decoding should result in the same string");
  Class repClass = [NSBitmapImageRep class];
  NSImageRep *imageRep = [[icon.image representations] lastObject];
  STAssertNotNil(imageRep, @"One image rep shoudl be there");
  STAssertTrue([imageRep isKindOfClass:repClass], @"Representation should be bitmap");
  NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)imageRep;
  NSData *pngData = [bitmapRep representationUsingType:NSPNGFileType properties:nil];
  STAssertTrue([pngData isEqualToData:_imageData], @"Image and PNG data shoudl be identical");
  
}

@end
