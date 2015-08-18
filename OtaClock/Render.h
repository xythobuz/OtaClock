//
//  Render.h
//  OtaClock
//
//  Created by Thomas Buck on 17.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainView;

@interface Render : NSObject

- (id)initWithParent:(MainView *)par;
- (NSSize)baseSize;

- (void)blinkDots;
- (void)drawMilitaryTime:(BOOL)mil;
- (void)drawAnimation:(NSInteger)state;
- (void)drawAlarmDate:(NSDate *)alarm;
- (void)drawDate:(BOOL)draw;
- (void)drawWithDate:(NSDate *)date;
- (void)drawWithEye:(NSInteger)eyeIndex;
- (void)drawInto:(NSView *)view;

@end
