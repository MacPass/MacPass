//
//  MPEntryPasswordAttributeViewController.m
//  MacPass
//
//  Created by Michael Starke on 18.10.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryPasswordAttributeViewController.h"
#import <HNHUi/HNHUi.h>
#import <KeePassKit/KeePassKit.h>

@interface MPEntryPasswordAttributeViewController ()

@property (strong) IBOutlet HNHUISecureTextField *passwordTextField;
@property (strong) IBOutlet NSButton *togglePasswordButton;
@property (strong) IBOutlet NSButton *generatePasswordButton;

@property (strong, nullable, readonly) KPKAttribute *representedAttribute;

@end

@implementation MPEntryPasswordAttributeViewController

@dynamic representedAttribute;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.togglePasswordButton.action = @selector(toggleDisplay:);
  self.togglePasswordButton.target = self.passwordTextField;
  
  __weak MPEntryPasswordAttributeViewController *welf = self;
  self.passwordTextField.buttonTitle = NSLocalizedString(@"COPY", "Button to copy the value of an Attribute");
  self.passwordTextField.buttonActionBlock =  ^void(NSTextField *tf) {
    NSText *text = [welf.view.window fieldEditor:NO forObject:welf.passwordTextField];
    if([text isKindOfClass:NSTextView.class]) {
      [welf textField:welf.passwordTextField textView:(NSTextView *)text performAction:@selector(copy:)];
    }
  };

}

- (void)updateValues {
  self.view.hidden = (!self.isEditor && self.representedAttribute.value.length == 0);
  self.passwordTextField.stringValue = self.representedAttribute.value ? self.representedAttribute.value : @"";
}

- (void)updateEditing {
  self.generatePasswordButton.hidden = !self.isEditor;
  self.passwordTextField.editable = self.isEditor;
  self.passwordTextField.selectable = YES;
}


@end
