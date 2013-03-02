//
//  MPButtonBar.h
//  MacPass
//
//  Created by michael starke on 28.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPGradientView.h"

/*
 Notifications and userInfo dictionary keys
 */
APPKIT_EXTERN NSString *const MPButtonBarSelectionChangedNotification;
/*
 Key in for the Index of the new selection. NSNumber with NSUInteger
 */
APPKIT_EXTERN NSString *const MPButtonBarSelectionIndexKey;

/*
 Exception thrown if an illegal delegate is used.
 */
APPKIT_EXTERN NSString *const MPButtonBarInvalidDelegateException;

@class MPButtonBar;

@protocol MPButtonBarDelegate <NSObject>

@required
- (NSUInteger)buttonsInButtonBar:(MPButtonBar *)buttonBar;
@optional
- (NSImage *)buttonBar:(MPButtonBar *)buttonBar imageAtIndex:(NSUInteger)index;
- (NSString *)buttonBar:(MPButtonBar *)buttonBar labelAtIndex:(NSUInteger)index;

/*
 A delegate that implements this function automatically gets registred to recive MPButtonBarSelectionDidChangeNotification
 The object in the notification is the buttonbar,
 The userDictionary contrains the following keys:
 MPButtonBarSelectionIndexKey;
 */
- (void)didChangeButtonSelection:(NSNotification *)notification;

@end

@interface MPButtonBar : MPGradientView

@property (nonatomic, assign) id<MPButtonBarDelegate> delegate;
@property (nonatomic, readonly) NSUInteger selectedIndex;
@property (nonatomic, readonly) BOOL hasSelection;


@end
