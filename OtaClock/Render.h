//
//  Render.h
//  OtaClock
//
//  Created by Thomas Buck on 17.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DROP_SHADOW_OFFSET 2.0
#define DROP_SHADOW_OFFSET_VIS (DROP_SHADOW_OFFSET / 2.0)
#define DROP_SHADOR_BLUR 0.0
#define DROP_SHADOW_RED 0.38
#define DROP_SHADOW_GREEN 0.36
#define DROP_SHADOW_BLUE 0.35
#define DROP_SHADOW_ALPHA 1.0

@class MainView;

@interface Render : NSObject

- (id)initWithParent:(MainView *)par;
- (NSSize)baseSize;

- (void)blinkDots;
- (void)drawDropShadow:(BOOL)shadow;
- (void)drawMilitaryTime:(BOOL)mil;
- (void)drawAnimation:(NSInteger)state;
- (void)drawAlarmDate:(NSDate *)alarm;
- (void)drawDate:(BOOL)draw;
- (void)drawWithDate:(NSDate *)date;
- (void)drawWithEye:(NSInteger)eyeIndex;
- (void)drawInto:(NSView *)view;

@end
