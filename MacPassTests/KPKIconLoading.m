//
//  KPKIconLoading.m
//  MacPass
//
//  Created by Michael Starke on 20.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KPKIcon.h"

@interface KPKIconLoading : XCTestCase {
  NSImage *_image;
  NSData *_imageData;
}
@end

@implementation KPKIconLoading

- (void)setUp {
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  _image = [myBundle imageForResource:@"image.png"];
  _imageData = [_image TIFFRepresentation];
  //_imageData = [_image.representations.lastObject representationUsingType:NSPNGFileType properties:nil];
}

- (void)tearDown {
  _image = nil;
  _imageData = nil;
}

- (void)testLoading {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *imageURL = [myBundle URLForImageResource:@"image.png"];
  KPKIcon *icon = [[KPKIcon alloc] initWithImageAtURL:imageURL];
  XCTAssertNotNil(icon, @"Icon should have been loaded");
  NSString *iconString = icon.encodedString;
  KPKIcon *iconFromString = [[KPKIcon alloc] initWithUUID:[NSUUID UUID] encodedString:iconString];
  XCTAssertEqualObjects(iconString, iconFromString.encodedString, @"Encoding and Decoding should result in the same string");
  Class repClass = [NSBitmapImageRep class];
  NSImageRep *imageRep = icon.image.representations.lastObject;
  XCTAssertNotNil(imageRep, @"One image rep shoudl be there");
  XCTAssertTrue([imageRep isKindOfClass:repClass], @"Representation should be bitmap");
  NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)imageRep;
  NSData *pngData = [bitmapRep representationUsingType:NSPNGFileType properties:@{}];
  XCTAssertEqualObjects(pngData, _imageData, @"Image and PNG data shoudl be identical");
}

@end
