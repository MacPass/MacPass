//
//  MPPathControl.h
//  MacPass
//
//  Created by Christoph Leimbrock on 8/7/17.
//

#import <Cocoa/Cocoa.h>

@protocol MPPathControlDelegate <NSPathControlDelegate>
- (void)pathControlDidBecomeKey:(NSPathControl *_Nullable)control;
@end

@interface MPPathControl : NSPathControl
@property (nullable, weak) id <MPPathControlDelegate> delegate;
@end
