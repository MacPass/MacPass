//
//  MPEntryAttributeViewController.m
//  MacPass
//
//  Created by Michael Starke on 14.10.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryAttributeViewController.h"
#import <HNHUi/HNHUi.h>
#import <KeePassKit/KeePassKit.h>
#import "MPPasteBoardController.h"

NSString *nameForDefaultKey(NSString *key) {
  static NSDictionary *mapping;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mapping = @{ kKPKTitleKey: NSLocalizedString(@"TITTLE_ATTRIBUTE_KEY", @"Localized name for title attribute"),
                 kKPKUsernameKey: NSLocalizedString(@"USERNAME_ATTRIBUTE_KEY", @"Localized name for username attribute"),
                 kKPKPasswordKey: NSLocalizedString(@"PASSEORD_ATTRIBUTE_KEY", @"Localized name for password attribute"),
                 kKPKURLKey: NSLocalizedString(@"URL_ATTRIBUTE_KEY", @"Localized name for URL attribute") };
  });
  return mapping[key];
}


@interface MPEntryAttributeViewController () {
  BOOL _isDefaultAttribute;
}

@end

@implementation MPEntryAttributeViewController

@synthesize isEditor = _isEditor;

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _isEditor = NO;
    _isDefaultAttribute = NO;
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  // set editor to false?
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *placeHolder = NSLocalizedString(@"NONE", "Placeholder text for input fields if no entry or group is selected");
  self.keyTextField.placeholderString = placeHolder;
  self.valueTextField.placeholderString = placeHolder;
  
  self.toggleProtectedButton.action = @selector(toggleDisplay:);
  self.toggleProtectedButton.target = self.valueTextField;
  
  [self updateValues];
  [self updateEditing];
  
  __weak MPEntryAttributeViewController *welf = self;
  self.valueTextField.buttonTitle = NSLocalizedString(@"COPY", "Button to copy the value of an Attribute");
  self.valueTextField.buttonActionBlock =  ^void(NSTextField *tf) {
    NSText *text = [welf.view.window fieldEditor:NO forObject:welf.valueTextField];
    if([text isKindOfClass:NSTextView.class]) {
      [welf textField:welf.valueTextField textView:(NSTextView *)text performAction:@selector(copy:)];
    }
  };
}

- (KPKAttribute *)representedAttribute {
  if([self.representedObject isKindOfClass:KPKAttribute.class]) {
    return (KPKAttribute *)self.representedObject;
  }
  return nil;
}

- (void)setIsEditor:(BOOL)isEditor {
  _isEditor = isEditor;
  [self updateEditing];
}

- (void)setRepresentedObject:(id)representedObject {
  if(self.representedAttribute) {
    [NSNotificationCenter.defaultCenter removeObserver:self name:KPKWillChangeAttributeNotification object:self.representedObject];
    [NSNotificationCenter.defaultCenter removeObserver:self name:KPKDidChangeAttributeNotification object:self.representedObject];
  }
  super.representedObject = representedObject;
  if(self.representedAttribute) {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:(@selector(_willChangeAttribute:))
                                               name:KPKWillChangeAttributeNotification
                                             object:self.representedAttribute];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:(@selector(_didChangeAttribute:))
                                               name:KPKDidChangeAttributeNotification
                                             object:self.representedAttribute];

  }
  _isDefaultAttribute = self.representedAttribute.isDefault;
  [self updateEditing];
  [self updateValues];
}

- (BOOL)textField:(NSTextField *)textField textView:(NSTextView *)textView performAction:(SEL)action {
  if(action != @selector(copy:)) {
    return YES;
  }
  
  // Only copy action
  MPPasteboardOverlayInfoType info = MPPasteboardOverlayInfoCustom;
  NSMutableString *selectedValue = [[NSMutableString alloc] init];
  for(NSValue *rangeValue in textView.selectedRanges) {
    [selectedValue appendString:[textView.string substringWithRange:rangeValue.rangeValue]];
  }
  if(selectedValue.length == 0) {
    [selectedValue setString:textField.stringValue];
  }
  NSString *name = @"";
  if([self.representedAttribute.key isEqual:kKPKUsernameKey]) {
    info = MPPasteboardOverlayInfoUsername;
  }
  else if([self.representedAttribute.key isEqual:kKPKPasswordKey]) {
    info = MPPasteboardOverlayInfoPassword;
  }
  else if([self.representedAttribute.key isEqual:kKPKURLKey]) {
    info = MPPasteboardOverlayInfoURL;
  }
  else if([self.representedAttribute.key isEqual:kKPKTitleKey]) {
    name = NSLocalizedString(@"TITLE", "Displayed name when title field was copied");
  }
  else {
    name = self.representedAttribute.key;
  }
  [MPPasteBoardController.defaultController copyObject:selectedValue overlayInfo:info name:name atView:self.view];
  return NO;
}


- (void)_willChangeAttribute:(NSNotification *)notification {
  // nothing to d
}

- (void)_didChangeAttribute:(NSNotification *)notification {
  [self updateValues];
}

- (void)updateValues {
  self.view.hidden = self.isEditor ? NO : self.representedAttribute.value.length == 0;
  
  NSString *localizedKey = nameForDefaultKey(self.representedAttribute.key);
  if(localizedKey) {
    self.keyTextField.stringValue = localizedKey;
  }
  else {
    self.keyTextField.stringValue = self.representedAttribute.key ? self.representedAttribute.key : @"";
  }
  self.keyTextField.stringValue = self.representedAttribute.key ? self.representedAttribute.key : @"";
  
  self.valueTextField.stringValue = self.representedAttribute.value ? self.representedAttribute.value : @"";
  self.valueTextField.showPassword = !self.representedAttribute.protect;
}

- (void)updateEditing {
  self.view.hidden = self.isEditor ? NO : self.representedAttribute.value.length == 0;
  self.keyTextField.editable = !_isDefaultAttribute && self.isEditor;
  self.valueTextField.editable = self.isEditor;
  self.keyTextField.selectable = YES;
  self.valueTextField.selectable = YES;
  self.toggleProtectedButton.hidden = _isDefaultAttribute;
  self.removeButton.hidden = !self.isEditor ? YES : _isDefaultAttribute;

  // set draws background first, since bezeld might have side effects
  self.valueTextField.drawsBackground = self.isEditor;
  self.valueTextField.bordered = self.isEditor;
  self.valueTextField.bezeled = self.isEditor;
}

-(void)commitChanges {
  if(!self.isEditor) {
    // do not commit changes if we are no editor!
  }
  // FIXME: better handling of key uniqueness
  if(!_isDefaultAttribute) {
    self.representedAttribute.key = self.keyTextField.stringValue;
  }
  self.representedAttribute.value = self.valueTextField.stringValue;
}

- (void)objectDidBeginEditing:(id<NSEditor>)editor {
  NSLog(@"%@: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
  [super objectDidBeginEditing:editor];
}

- (void)objectDidEndEditing:(id<NSEditor>)editor {
  NSLog(@"%@: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
  [super objectDidEndEditing:editor];
}

- (BOOL)commitEditing {
  NSLog(@"%@: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
  return [super commitEditing];
}

- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable *)error {
  NSLog(@"%@: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
  return [super commitEditingAndReturnError:error];
}

- (void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo {
  NSLog(@"%@: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
  [super commitEditingWithDelegate:delegate didCommitSelector:didCommitSelector contextInfo:contextInfo];
}

@end

