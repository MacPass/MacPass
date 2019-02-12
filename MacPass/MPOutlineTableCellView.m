//
//  MPOutlineTableCellView.m
//  MacPass
//
//  Created by Michael Starke on 26.09.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineTableCellView.h"

@implementation MPOutlineTableCellView

@synthesize count = _count;

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if(self) {
    [self _setupDefaults];
    [self _updateCountDisplay];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if(self) {
    [self _setupDefaults];
    if([decoder containsValueForKey:NSStringFromSelector(@selector(count))]) {
      _count = [decoder decodeIntegerForKey:NSStringFromSelector(@selector(count))];
    }
    if([decoder containsValueForKey:NSStringFromSelector(@selector(hideZeroCount))]) {
      _hideZeroCount = [decoder decodeBoolForKey:NSStringFromSelector(@selector(hideZeroCount))];
    }
    [self _updateCountDisplay];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeBool:_hideZeroCount forKey:NSStringFromSelector(@selector(hideZeroCount))];
  [aCoder encodeInteger:_count forKey:NSStringFromSelector(@selector(count))];
}

- (void)awakeFromNib {
  [self _updateCountDisplay];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  super.backgroundStyle = backgroundStyle;
  self.countButton.cell.backgroundStyle = backgroundStyle;
}

- (void)_setupDefaults {
  _count = 0;
  _hideZeroCount = YES;
}

- (void)setCount:(NSInteger)count {
  if(_count != count) {
    _count = count;
    [self _updateCountDisplay];
  }
}

- (void)setHideZeroCount:(BOOL)hideZeroCount {
  if(_hideZeroCount != hideZeroCount) {
    _hideZeroCount = hideZeroCount;
    [self _updateCountDisplay];
  }
}

- (void)_updateCountDisplay {
  [((NSButtonCell *)self.countButton.cell) setHighlightsBy:0];
  self.countButton.title = [NSString stringWithFormat:@"%ld", _count];
  self.countButton.hidden = (self.hideZeroCount && self.count == 0);
}

@end
