//
//  Render.h
//  OtaClock
//
//  Created by Thomas Buck on 17.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Render : NSObject

- (id)init;
- (NSSize)baseSize;

- (void)drawWith:(NSInteger)eyeIndex;
- (void)drawInto:(NSView *)view;

@end
