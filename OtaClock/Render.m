//
//  Render.m
//  OtaClock
//
//  Created by Thomas Buck on 17.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "MainView.h"
#import "Render.h"

#define FULL_IMAGE_WIDTH 86
#define FULL_IMAGE_HEIGHT 80
#define BUBBLE_Y_OFFSET 45
#define OTACON_X_OFFSET 1
#define EYE_X_OFFSET 60
#define EYE_Y_OFFSET 45

#define FONT_DAYS_WIDTH 17
#define FONT_DAYS_HEIGHT 3
#define FONT_DAYS_PADDING 1
#define FONT_DAYS_X_OFFSET 31
#define FONT_DAYS_Y_OFFSET 72

@interface Render ()

@property (assign) CGImageRef otaconGraphic, bubbleGraphic;
@property (assign) CGImageRef eye0, eye1, eye2, eye3, eye4;
@property (assign) CGImageRef fontMonday, fontTuesday, fontWednesday, fontThursday, fontFriday, fontSaturday, fontSunday;
@property (assign) NSInteger eyeToDraw, dayOfWeek;

@property (assign) NSSize fullSize;
@property (assign) CGContextRef drawContext;

@property (weak) MainView *parent;

@end

@implementation Render

@synthesize otaconGraphic, bubbleGraphic;
@synthesize eye0, eye1, eye2, eye3, eye4;
@synthesize fontMonday, fontTuesday, fontWednesday, fontThursday, fontFriday, fontSaturday, fontSunday;
@synthesize eyeToDraw, dayOfWeek;

@synthesize fullSize;
@synthesize drawContext;
@synthesize parent;

- (CGImageRef)eyeHelper:(NSInteger)index {
    if (index == 0) return eye0;
    if (index == 1) return eye1;
    if (index == 2) return eye2;
    if (index == 3) return eye3;
    if (index == 4) return eye4;
    
    NSLog(@"Render:eyeHelper:%ld unknown index!", (long)index);
    return eye0;
}

- (CGImageRef)dayHelper:(NSInteger)index {
    if (index == -1) return fontSunday;
    if (index == 0) return fontMonday;
    if (index == 1) return fontTuesday;
    if (index == 2) return fontWednesday;
    if (index == 3) return fontThursday;
    if (index == 4) return fontFriday;
    if (index == 5) return fontSaturday;
    if (index == 6) return fontSunday;
    
    NSLog(@"Render:dayHelper:%ld unknown index!", (long)index);
    return fontMonday;
}

- (id)initWithParent:(MainView *)par {
    self = [super init];
    if (self == nil) return nil;
    
    parent = par;
    
    NSImage *otaconImage = [NSImage imageNamed:@"otacon"];
    NSImage *bubbleImage = [NSImage imageNamed:@"bubble"];
    NSImage *eye0Image = [NSImage imageNamed:@"eyes_0"];
    NSImage *eye1Image = [NSImage imageNamed:@"eyes_1"];
    NSImage *eye2Image = [NSImage imageNamed:@"eyes_2"];
    NSImage *eye3Image = [NSImage imageNamed:@"eyes_3"];
    NSImage *eye4Image = [NSImage imageNamed:@"eyes_4"];
    NSImage *fontDaysImage = [NSImage imageNamed:@"font_days"];
    
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithAttributes:nil];
    
    otaconGraphic = [otaconImage CGImageForProposedRect:nil context:context hints:nil];
    bubbleGraphic = [bubbleImage CGImageForProposedRect:nil context:context hints:nil];
    eye0 = [eye0Image CGImageForProposedRect:nil context:context hints:nil];
    eye1 = [eye1Image CGImageForProposedRect:nil context:context hints:nil];
    eye2 = [eye2Image CGImageForProposedRect:nil context:context hints:nil];
    eye3 = [eye3Image CGImageForProposedRect:nil context:context hints:nil];
    eye4 = [eye4Image CGImageForProposedRect:nil context:context hints:nil];
    
    CGImageRef fontDays = [fontDaysImage CGImageForProposedRect:nil context:context hints:nil];
    NSRect rectDay;
    rectDay.size.width = FONT_DAYS_WIDTH;
    rectDay.size.height = FONT_DAYS_HEIGHT;
    rectDay.origin.x = 0;
    rectDay.origin.y = 0;
    fontMonday = CGImageCreateWithImageInRect(fontDays, rectDay);
    rectDay.origin.y += FONT_DAYS_HEIGHT + FONT_DAYS_PADDING;
    fontTuesday = CGImageCreateWithImageInRect(fontDays, rectDay);
    rectDay.origin.y += FONT_DAYS_HEIGHT + FONT_DAYS_PADDING;
    fontWednesday = CGImageCreateWithImageInRect(fontDays, rectDay);
    rectDay.origin.y += FONT_DAYS_HEIGHT + FONT_DAYS_PADDING;
    fontThursday = CGImageCreateWithImageInRect(fontDays, rectDay);
    rectDay.origin.y += FONT_DAYS_HEIGHT + FONT_DAYS_PADDING;
    fontFriday = CGImageCreateWithImageInRect(fontDays, rectDay);
    rectDay.origin.y += FONT_DAYS_HEIGHT + FONT_DAYS_PADDING;
    fontSaturday = CGImageCreateWithImageInRect(fontDays, rectDay);
    rectDay.origin.y += FONT_DAYS_HEIGHT + FONT_DAYS_PADDING;
    fontSunday = CGImageCreateWithImageInRect(fontDays, rectDay);
    
    fullSize.width = FULL_IMAGE_WIDTH;
    fullSize.height = FULL_IMAGE_HEIGHT;
    
    drawContext = CGBitmapContextCreate(NULL, fullSize.width, fullSize.height, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    
    eyeToDraw = 0;
    dayOfWeek = 0;
    
    return self;
}

- (NSSize)baseSize {
    return fullSize;
}

- (void)drawWithDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    dayOfWeek = [components weekday] - 2;
    
    
    // Check if something changed, if so, set needsDisplay
    // if (bla) {
    //     parent.needsDisplay = YES;
    // }
}

- (void)drawWithEye:(NSInteger)eyeIndex {
    eyeToDraw = eyeIndex;
}

- (void)drawInto:(NSView *)view {
    // Clear entire canvas
    CGRect size;
    size.size = fullSize;
    size.origin = NSZeroPoint;
    CGContextClearRect(drawContext, size);
    
    // Draw Speech Bubble
    size.size.width = CGImageGetWidth(bubbleGraphic);
    size.size.height = CGImageGetHeight(bubbleGraphic);
    size.origin.y = BUBBLE_Y_OFFSET;
    CGContextDrawImage(drawContext, size, bubbleGraphic);
    
    // Draw Date

    // Draw Day of Week
    CGImageRef day = [self dayHelper:dayOfWeek];
    size.size.width = FONT_DAYS_WIDTH;
    size.size.height = FONT_DAYS_HEIGHT;
    size.origin.x = FONT_DAYS_X_OFFSET;
    size.origin.y = FONT_DAYS_Y_OFFSET;
    CGContextDrawImage(drawContext, size, day);
    
    // Draw Time
    
    // Draw Otacon
    size.size.width = CGImageGetWidth(otaconGraphic);
    size.size.height = CGImageGetHeight(otaconGraphic);
    size.origin = NSZeroPoint;
    size.origin.x = CGImageGetWidth(bubbleGraphic) + OTACON_X_OFFSET;
    CGContextDrawImage(drawContext, size, otaconGraphic);
    
    // Draw eyes
    size.size.width = CGImageGetWidth([self eyeHelper:eyeToDraw]);
    size.size.height = CGImageGetHeight([self eyeHelper:eyeToDraw]);
    size.origin.x = EYE_X_OFFSET;
    size.origin.y = EYE_Y_OFFSET;
    CGContextDrawImage(drawContext, size, [self eyeHelper:eyeToDraw]);
    
    // Render resulting canvas into bitmap and scale this into our window
    CGImageRef drawnImage = CGBitmapContextCreateImage(drawContext);
    NSImage *result = [[NSImage alloc] initWithCGImage:drawnImage size:fullSize];
    [result drawInRect:[view bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:NSImageInterpolationNone] forKey:NSImageHintInterpolation]];
}

@end
