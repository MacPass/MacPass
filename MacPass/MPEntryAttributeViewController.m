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
#import "MPInspectorEditorView.h"

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
  _isEditor = NO;
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didEnterMouse:) name:MPInspectorEditorViewMouseEnteredNotification object:self.view];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didExitMouse:) name:MPInspectorEditorViewMouseExitedNotification object:self.view];
  
  self.toggleProtectedButton.action = @selector(toggleDisplay:);
  self.toggleProtectedButton.target = self.valueTextField;
  
  self.actionButton.action = @selector(_copyText:);
  self.actionButton.target = self;
  self.actionButton.hidden = YES;
  self.actionButton.title = NSLocalizedString(@"COPY", "Button title for copying an attribute value");
  
  [self updateValuesAndEditing];
}

- (KPKAttribute *)representedAttribute {
  if([self.representedObject isKindOfClass:KPKAttribute.class]) {
    return (KPKAttribute *)self.representedObject;
  }
  return nil;
}

- (void)setIsEditor:(BOOL)isEditor {
  _isEditor = isEditor;
  [self updateValuesAndEditing];
}

- (void)setRepresentedObject:(id)representedObject {
  [self.valueTextField unbind:NSValueBinding];
  [self.keyTextField unbind:NSValueBinding];
  
  if(self.representedAttribute) {
    [NSNotificationCenter.defaultCenter removeObserver:self name:KPKDidChangeAttributeNotification object:self.representedObject];
  }
  super.representedObject = representedObject;
  if(self.representedAttribute) {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:(@selector(_didChangeAttribute:))
                                               name:KPKDidChangeAttributeNotification
                                             object:self.representedAttribute];
    
  }
  _isDefaultAttribute = self.representedAttribute.isDefault;
  
  NSDictionary *bindingOptions = @{ NSNullPlaceholderBindingOption :  NSLocalizedString(@"NONE", "Placeholder text for input fields if no entry or group is selected") };
  NSString *valueKeyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(value))];
  [self.valueTextField bind:NSValueBinding toObject:self withKeyPath:valueKeyPath options:bindingOptions];
  
  if(!_isDefaultAttribute) {
    NSString *keyKeyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(key))];
    [self.keyTextField bind:NSValueBinding toObject:self withKeyPath:keyKeyPath options:bindingOptions];
  }
  else {
    NSString *localizedKey = nameForDefaultKey(self.representedAttribute.key);
    if(localizedKey) {
      self.keyTextField.stringValue = localizedKey;
    }
    else {
      self.keyTextField.stringValue = self.representedAttribute.key ? self.representedAttribute.key : @"";
    }
  }
  
  [self updateValuesAndEditing];
}

- (void)_copyText:(id)sender {
  [self performCopyForText:self.valueTextField.stringValue];
}

- (BOOL)textField:(NSTextField *)textField textView:(NSTextView *)textView performAction:(SEL)action {
  if(action != @selector(copy:)) {
    return YES;
  }
  
  // Only copy action
  
  NSMutableString *selectedValue = [[NSMutableString alloc] init];
  for(NSValue *rangeValue in textView.selectedRanges) {
    [selectedValue appendString:[textView.string substringWithRange:rangeValue.rangeValue]];
  }
  if(selectedValue.length == 0) {
    [selectedValue setString:textField.stringValue];
  }
  [self performCopyForText:selectedValue];
  return NO;
}

- (void)performCopyForText:(NSString *)text {
  
  MPPasteboardOverlayInfoType info = MPPasteboardOverlayInfoCustom;
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
  [MPPasteBoardController.defaultController copyObject:text overlayInfo:info name:name atView:self.view];
}

- (void)_didChangeAttribute:(NSNotification *)notification {
  [self updateValuesAndEditing];
}

- (void)updateValuesAndEditing {
  /* values */
  self.view.hidden = self.isEditor ? NO : self.representedAttribute.value.length == 0;
  
  self.valueTextField.showPassword = !self.representedAttribute.protect;
  
  /* editor */
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

- (void)_didEnterMouse:(NSNotification *)notification {
  self.actionButton.hidden = self.isEditor;
}

- (void)_didExitMouse:(NSNotification *)notification {
  self.actionButton.hidden = YES;
}

- (void)commitChanges {
  // to nothing
}

- (void)objectDidBeginEditing:(id<NSEditor>)editor {
  [self.view.window.windowController.document objectDidBeginEditing:editor];
}

- (void)objectDidEndEditing:(id<NSEditor>)editor {
  [self.view.window.windowController.document objectDidEndEditing:editor];
}

@end

