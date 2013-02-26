//
//  MPPathBarItemView.m
//  MacPass
//
//  Created by michael starke on 22.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathBarItemView.h"

#define IMAGE_TO_TEXT_MARGIN 5.0

@interface MPPathBarItemView ()

@property (retain) NSImageView *imageView;
@property (retain) NSTextField *textField;

@end

@implementation MPPathBarItemView

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if(self) {
    
    _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 24)];
    [[_imageView cell] setImageAlignment:NSImageAlignCenter];
    [[_imageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[_imageView cell] setBordered:NO];
    [[_imageView cell] setDrawsBackground:NO];
    [_imageView setImage:[NSImage imageNamed:NSImageNameActionTemplate ]];
    
    _textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 24)];
    [_textField setBordered:NO];
    [_textField setFont:[NSFont systemFontOfSize:13]];
    [_textField setDrawsBackground:NO];
    [_textField setEditable:NO];
    [_textField setSelectable:NO];
    [[_textField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [_textField setStringValue:@"Boo"];
    
    
    [self addSubview:_textField];
    [self addSubview:_imageView];
    
    
    [self sizeToFit];
    
    [self needsLayout];
  }
  return self;
}

- (void)setText:(NSString *)text {
  if(_text != text) {
    [_text release];
    _text = [text retain];
    [self.textField setStringValue:text];
    [self sizeToFit];
  }
}

- (void)setImage:(NSImage *)image {
  if(_image != image) {
    [_image release];
    _image = [image retain];
    [_imageView setImage:image];
    [self sizeToFit];
  }
}

- (void)sizeToFit {
  
  const BOOL isAutoResize = [self autoresizesSubviews];/* Disable autoresizing */
  [self setAutoresizesSubviews:NO];
  NSRect superFrame = [self frame];
  /*
   Let our subviews calculate their sizes
   */
  [self.textField sizeToFit];
  //[self.imageView sizeToFit];
  NSRect textFrame = [self.textField frame];
  NSRect imageFrame = [self.imageView frame];
  /*
   Determine our size
   */
  CGFloat height = MAX(textFrame.size.height, imageFrame.size.height);
  CGFloat width = textFrame.size.width + IMAGE_TO_TEXT_MARGIN + imageFrame.size.width;
  
  [self setFrame:NSMakeRect(superFrame.origin.x, superFrame.origin.y, width, height)];

  imageFrame.origin.x = 0;
  imageFrame.origin.y = 0;
  imageFrame.size.height = height;
  textFrame.origin.x = imageFrame.size.width + IMAGE_TO_TEXT_MARGIN;
  textFrame.origin.y = 0;
  textFrame.size.height = height;
  
  [self.textField setFrame:textFrame];
  [self.imageView setFrame:imageFrame];
  /* Reset the autoresizing */
  [self setAutoresizesSubviews:isAutoResize];
}

@end
