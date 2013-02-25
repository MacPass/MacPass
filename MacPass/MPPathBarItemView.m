//
//  MPPathBarItemView.m
//  MacPass
//
//  Created by michael starke on 22.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathBarItemView.h"

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
    
    _textField = [[NSTextField alloc] initWithFrame:NSMakeRect([_imageView frame].size.width + 5, 0, 20, 24)];
    [_textField setBordered:NO];
    [_textField setFont:[NSFont systemFontOfSize:13]];
    [_textField setDrawsBackground:NO];
    [_textField setEditable:NO];
    [_textField setSelectable:NO];
    [[_textField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [_textField setStringValue:@"Boo"];
    [_textField sizeToFit];
    [self addSubview:_textField];
    [self addSubview:_imageView];
    
//    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_imageView, _textField);
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_imageView(24)]-|"
//                                                                 options:0
//                                                                 metrics:nil
//                                                                   views:viewDictionary]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_imageView(24)]-|"
//                                                                 options:0
//                                                                 metrics:nil
//                                                                   views:viewDictionary]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_imageView]-|"
//                                                                options:0
//                                                                metrics:nil
//                                                                  views:viewDictionary]];
//
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textField]-|"
//                                                                 options:0
//                                                                 metrics:nil
//                                                                   views:viewDictionary]];
    
    
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
  [self.textField sizeToFit];
  [self.imageView sizeToFit];
  NSRect textFrame = [self.textField frame];
  NSRect imageFrame = [self.imageView frame];

  // nudge the textframe
  textFrame.origin.x = imageFrame.size.width;
  [self.textField setFrame:textFrame];
  
  NSRect frame = NSMakeRect(0, 0,textFrame.size.width + imageFrame.size.width, textFrame.size.height);
  [self setFrame:frame];
}

@end
