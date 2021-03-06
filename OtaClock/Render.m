//
//  Render.m
//  OtaClock
//
//  Created by Thomas Buck on 17.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "MainView.h"
#import "MainWindow.h"
#import "Render.h"

#define FULL_IMAGE_WIDTH 86
#define FULL_IMAGE_HEIGHT 80
#define BUBBLE_Y_OFFSET 45
#define OTACON_0_X_OFFSET 1
#define OTACON_1_X_OFFSET 0
#define OTACON_2_X_OFFSET -6
#define OTACON_3_X_OFFSET -6
#define EYE_X_OFFSET 60
#define EYE_Y_OFFSET 45

#define FONT_DAYS_WIDTH 17
#define FONT_DAYS_HEIGHT 3
#define FONT_DAYS_PADDING 1
#define FONT_DAYS_X_OFFSET 31
#define FONT_DAYS_Y_OFFSET 72

#define FONT_LARGE_WIDTH 6
#define FONT_LARGE_HEIGHT 7
#define FONT_LARGE_PADDING 1

#define FONT_LARGE_Y_OFFSET 63
#define FONT_LARGE_X0_OFFSET 5
#define FONT_LARGE_X1_OFFSET 12
#define FONT_LARGE_X2_OFFSET 21
#define FONT_LARGE_X3_OFFSET 28
#define FONT_LARGE_X4_OFFSET 37
#define FONT_LARGE_X5_OFFSET 44

#define FONT_SMALL_WIDTH 4
#define FONT_SMALL_HEIGHT 5
#define FONT_SMALL_PADDING 1

#define FONT_SMALL_DATE_Y_OFFSET 71
#define FONT_SMALL_DATE_X0_OFFSET 3
#define FONT_SMALL_DATE_X1_OFFSET 8
#define FONT_SMALL_DATE_X2_OFFSET 17
#define FONT_SMALL_DATE_X3_OFFSET 22

#define FONT_SMALL_ALARM_Y_OFFSET 57
#define FONT_SMALL_ALARM_X0_OFFSET 29
#define FONT_SMALL_ALARM_X1_OFFSET 34
#define FONT_SMALL_ALARM_X2_OFFSET 41
#define FONT_SMALL_ALARM_X3_OFFSET 46

#define FONT_TIME_WIDTH 11
#define FONT_TIME_HEIGHT 3
#define FONT_TIME_PADDING 1

#define ALARM_X_OFFSET 5
#define ALARM_Y_OFFSET 57

#define DOTS_TIME_Y_OFFSET 63
#define DOTS_TIME_X0_OFFSET 18
#define DOTS_TIME_X1_OFFSET 34

#define DOTS_ALARM_X_OFFSET 38
#define DOTS_ALARM_Y_OFFSET 57

#define BLANK_OFFSET_X 13
#define BLANK_OFFSET_Y 71

@interface Render ()

@property (assign) CGImageRef otaconGraphic, bubbleGraphic, alarmGraphic, blankGraphic;
@property (assign) CGImageRef otacon1Graphic, otacon2Graphic, otacon3Graphic;
@property (assign) CGImageRef eye0, eye1, eye2, eye3, eye4, dotSmallGraphic, dotLargeGraphic;
@property (assign) CGImageRef fontMonday, fontTuesday, fontWednesday, fontThursday, fontFriday, fontSaturday, fontSunday, fontAM, fontPM;
@property (assign) CGImageRef fontSmall1, fontSmall2, fontSmall3, fontSmall4, fontSmall5, fontSmall6, fontSmall7, fontSmall8, fontSmall9, fontSmall0;
@property (assign) CGImageRef fontLarge1, fontLarge2, fontLarge3, fontLarge4, fontLarge5, fontLarge6, fontLarge7, fontLarge8, fontLarge9, fontLarge0;

@property (assign) NSInteger eyeToDraw, dayOfWeek, animState;
@property (assign) NSInteger dateDigit0, dateDigit1, dateDigit2, dateDigit3;
@property (assign) NSInteger alarmDigit0, alarmDigit1, alarmDigit2, alarmDigit3;
@property (assign) NSInteger timeDigit0, timeDigit1, timeDigit2, timeDigit3, timeDigit4, timeDigit5;
@property (assign) BOOL alarmSign, alarmDots, timeDots, drawDate, militaryTime, isAfternoon, dropShadow;

@property (assign) NSSize fullSize;
@property (assign) CGContextRef drawContext;

@property (weak) MainView *parent;

@end

@implementation Render

@synthesize otaconGraphic, bubbleGraphic, alarmGraphic, blankGraphic;
@synthesize otacon1Graphic, otacon2Graphic, otacon3Graphic;
@synthesize eye0, eye1, eye2, eye3, eye4, dotSmallGraphic, dotLargeGraphic;
@synthesize fontMonday, fontTuesday, fontWednesday, fontThursday, fontFriday, fontSaturday, fontSunday, fontAM, fontPM;
@synthesize fontSmall1, fontSmall2, fontSmall3, fontSmall4, fontSmall5, fontSmall6, fontSmall7, fontSmall8, fontSmall9, fontSmall0;
@synthesize fontLarge1, fontLarge2, fontLarge3, fontLarge4, fontLarge5, fontLarge6, fontLarge7, fontLarge8, fontLarge9, fontLarge0;

@synthesize eyeToDraw, dayOfWeek, animState;
@synthesize dateDigit0, dateDigit1, dateDigit2, dateDigit3;
@synthesize alarmDigit0, alarmDigit1, alarmDigit2, alarmDigit3;
@synthesize timeDigit0, timeDigit1, timeDigit2, timeDigit3, timeDigit4, timeDigit5;
@synthesize alarmSign, alarmDots, timeDots, drawDate, militaryTime, isAfternoon, dropShadow;

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

- (CGImageRef)smallHelper:(NSInteger)index {
    if (index == 0) return fontSmall0;
    if (index == 1) return fontSmall1;
    if (index == 2) return fontSmall2;
    if (index == 3) return fontSmall3;
    if (index == 4) return fontSmall4;
    if (index == 5) return fontSmall5;
    if (index == 6) return fontSmall6;
    if (index == 7) return fontSmall7;
    if (index == 8) return fontSmall8;
    if (index == 9) return fontSmall9;
    
    NSLog(@"Render:smallHelper:%ld unknown index!", (long)index);
    return fontSmall0;
}

- (CGImageRef)largeHelper:(NSInteger)index {
    if (index == 0) return fontLarge0;
    if (index == 1) return fontLarge1;
    if (index == 2) return fontLarge2;
    if (index == 3) return fontLarge3;
    if (index == 4) return fontLarge4;
    if (index == 5) return fontLarge5;
    if (index == 6) return fontLarge6;
    if (index == 7) return fontLarge7;
    if (index == 8) return fontLarge8;
    if (index == 9) return fontLarge9;
    
    NSLog(@"Render:largeHelper:%ld unknown index!", (long)index);
    return fontLarge0;
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
    NSImage *fontSmallImage = [NSImage imageNamed:@"font_small"];
    NSImage *fontLargeImage = [NSImage imageNamed:@"font_large"];
    NSImage *fontTimeImage = [NSImage imageNamed:@"font_time"];
    NSImage *alarmImage = [NSImage imageNamed:@"alarm"];
    NSImage *dotsSmallImage = [NSImage imageNamed:@"dots_small"];
    NSImage *dotsLargeImage = [NSImage imageNamed:@"dots_large"];
    NSImage *blankImage = [NSImage imageNamed:@"blank"];
    NSImage *otacon1Image = [NSImage imageNamed:@"otacon_1"];
    NSImage *otacon2Image = [NSImage imageNamed:@"otacon_2"];
    NSImage *otacon3Image = [NSImage imageNamed:@"otacon_3"];
    
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithAttributes:nil];
    
    otaconGraphic = [otaconImage CGImageForProposedRect:nil context:context hints:nil];
    bubbleGraphic = [bubbleImage CGImageForProposedRect:nil context:context hints:nil];
    alarmGraphic = [alarmImage CGImageForProposedRect:nil context:context hints:nil];
    dotSmallGraphic = [dotsSmallImage CGImageForProposedRect:nil context:context hints:nil];
    dotLargeGraphic = [dotsLargeImage CGImageForProposedRect:nil context:context hints:nil];
    blankGraphic = [blankImage CGImageForProposedRect:nil context:context hints:nil];
    eye0 = [eye0Image CGImageForProposedRect:nil context:context hints:nil];
    eye1 = [eye1Image CGImageForProposedRect:nil context:context hints:nil];
    eye2 = [eye2Image CGImageForProposedRect:nil context:context hints:nil];
    eye3 = [eye3Image CGImageForProposedRect:nil context:context hints:nil];
    eye4 = [eye4Image CGImageForProposedRect:nil context:context hints:nil];
    otacon1Graphic = [otacon1Image CGImageForProposedRect:nil context:context hints:nil];
    otacon2Graphic = [otacon2Image CGImageForProposedRect:nil context:context hints:nil];
    otacon3Graphic = [otacon3Image CGImageForProposedRect:nil context:context hints:nil];
    
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
    
    NSRect rect;
    CGImageRef fontSmall = [fontSmallImage CGImageForProposedRect:nil context:context hints:nil];
    rect.size.width = FONT_SMALL_WIDTH;
    rect.size.height = FONT_SMALL_HEIGHT;
    rect.origin.x = 0;
    rect.origin.y = 0;
    fontSmall0 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall1 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall2 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall3 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall4 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall5 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall6 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall7 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall8 = CGImageCreateWithImageInRect(fontSmall, rect);
    rect.origin.x += FONT_SMALL_WIDTH + FONT_SMALL_PADDING;
    fontSmall9 = CGImageCreateWithImageInRect(fontSmall, rect);
    
    CGImageRef fontLarge = [fontLargeImage CGImageForProposedRect:nil context:context hints:nil];
    rect.size.width = FONT_LARGE_WIDTH;
    rect.size.height = FONT_LARGE_HEIGHT;
    rect.origin.x = 0;
    rect.origin.y = 0;
    fontLarge0 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge1 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge2 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge3 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge4 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge5 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge6 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge7 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge8 = CGImageCreateWithImageInRect(fontLarge, rect);
    rect.origin.x += FONT_LARGE_WIDTH + FONT_LARGE_PADDING;
    fontLarge9 = CGImageCreateWithImageInRect(fontLarge, rect);
    
    CGImageRef fontTime = [fontTimeImage CGImageForProposedRect:nil context:context hints:nil];
    rect.size.width = FONT_TIME_WIDTH;
    rect.size.height = FONT_TIME_HEIGHT;
    rect.origin.x = 0;
    rect.origin.y = 0;
    fontAM = CGImageCreateWithImageInRect(fontTime, rect);
    rect.origin.y += FONT_TIME_HEIGHT + FONT_TIME_PADDING;
    fontPM = CGImageCreateWithImageInRect(fontTime, rect);
    
    fullSize.width = FULL_IMAGE_WIDTH;
    fullSize.height = FULL_IMAGE_HEIGHT;
    
    drawContext = CGBitmapContextCreate(NULL, fullSize.width, fullSize.height, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    
    animState = 0;
    eyeToDraw = 0;
    dayOfWeek = 0;
    dateDigit0 = 1;
    dateDigit1 = 8;
    dateDigit2 = 8;
    dateDigit3 = 8;
    timeDigit0 = 8;
    timeDigit1 = 8;
    timeDigit2 = 8;
    timeDigit3 = 8;
    timeDigit4 = 8;
    timeDigit5 = 8;
    timeDots = YES;
    militaryTime = NO;
    isAfternoon = NO;
    
    alarmDigit0 = -1;
    alarmDigit1 = -1;
    alarmDigit2 = -1;
    alarmDigit3 = -1;
    alarmSign = NO;
    alarmDots = NO;
    
    dropShadow = NO;
    
    return self;
}

- (NSSize)baseSize {
    return fullSize;
}

#define CONVERT_DECIMAL(num, ten, one) do { \
    if (num >= 50) { \
        ten = 5; \
        one = num - 50; \
    } else if (num >= 40) { \
        ten = 4; \
        one = num - 40; \
    } else if (num >= 30) { \
        ten = 3; \
        one = num - 30; \
    } else if (num >= 20) { \
        ten = 2; \
        one = num - 20; \
    } else if (num >= 10) { \
        ten = 1; \
        one = num - 10; \
    } else { \
        ten = 0; \
        one = num; \
    } \
} while (0);

- (void)blinkDots {
    timeDots = !timeDots;
    if ((alarmDigit0 != -1) || (alarmDigit1 != -1) || (alarmDigit2 != -1) || (alarmDigit3 != -1)) {
        alarmDots = timeDots;
    }
}

- (void)drawDropShadow:(BOOL)shadow {
    dropShadow = shadow;
    [self drawWithDate:[NSDate date]];
}

- (void)drawMilitaryTime:(BOOL)mil {
    militaryTime = mil;
    [self drawWithDate:[NSDate date]];
}

- (void)drawAnimation:(NSInteger)state {
    if (animState != state) {
        [[self.parent window] invalidateShadow];
    }
    animState = state;
}

- (void)drawAlarmDate:(NSDate *)alarm {
    if (alarm == nil) {
        alarmDigit0 = -1;
        alarmDigit1 = -1;
        alarmDigit2 = -1;
        alarmDigit3 = -1;
        alarmSign = NO;
        alarmDots = NO;
        return;
    }
    
    alarmSign = YES;
    alarmDots = YES;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:alarm];
    CONVERT_DECIMAL([components hour], alarmDigit0, alarmDigit1);
    CONVERT_DECIMAL([components minute], alarmDigit2, alarmDigit3);
}

- (void)drawDate:(BOOL)draw {
    drawDate = draw;
}

- (void)drawWithDate:(NSDate *)date {
    NSCalendarUnit comps = NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:comps fromDate:date];
    dayOfWeek = [components weekday] - 2; // map sun=1 to sun=-1
    
    // Convert from military time to am/pm format if neccessary
    NSInteger hour = [components hour];
    if (militaryTime == NO) {
        if (hour == 0) {
            hour = 12;
            isAfternoon = false;
        } else if (hour == 12) {
            isAfternoon = true;
        } else if (hour > 12) {
            isAfternoon = true;
            hour -= 12;
        } else if (hour < 12) {
            isAfternoon = false;
        }
    }
    
    CONVERT_DECIMAL([components month], dateDigit0, dateDigit1);
    CONVERT_DECIMAL([components day], dateDigit2, dateDigit3);
    CONVERT_DECIMAL(hour, timeDigit0, timeDigit1);
    CONVERT_DECIMAL([components minute], timeDigit2, timeDigit3);
    CONVERT_DECIMAL([components second], timeDigit4, timeDigit5);
    
    // Remove leading hour zero when drawing in am/pm mode
    if (militaryTime == NO) {
        if (timeDigit0 == 0) {
            timeDigit0 = -1;
        }
    }
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

    if (drawDate == YES) {
        // Draw Date
        size.size.width = FONT_SMALL_WIDTH;
        size.size.height = FONT_SMALL_HEIGHT;
        size.origin.y = FONT_SMALL_DATE_Y_OFFSET;
        if (dateDigit0 == 1) {
            size.origin.x = FONT_SMALL_DATE_X0_OFFSET;
            CGContextDrawImage(drawContext, size, fontSmall1);
        }
        if ((dateDigit1 >= 0) && (dateDigit1 <= 9)) {
            size.origin.x = FONT_SMALL_DATE_X1_OFFSET;
            CGContextDrawImage(drawContext, size, [self smallHelper:dateDigit1]);
        }
        if ((dateDigit2 >= 0) && (dateDigit2 <= 9)) {
            size.origin.x = FONT_SMALL_DATE_X2_OFFSET;
            CGContextDrawImage(drawContext, size, [self smallHelper:dateDigit2]);
        }
        if ((dateDigit3 >= 0) && (dateDigit3 <= 9)) {
            size.origin.x = FONT_SMALL_DATE_X3_OFFSET;
            CGContextDrawImage(drawContext, size, [self smallHelper:dateDigit3]);
        }

        // Draw Day of Week
        CGImageRef day = [self dayHelper:dayOfWeek];
        size.size.width = FONT_DAYS_WIDTH;
        size.size.height = FONT_DAYS_HEIGHT;
        size.origin.x = FONT_DAYS_X_OFFSET;
        size.origin.y = FONT_DAYS_Y_OFFSET;
        CGContextDrawImage(drawContext, size, day);
    } else {
        // Block unneeded date elements
        size.size.width = CGImageGetWidth(blankGraphic);
        size.size.height = CGImageGetHeight(blankGraphic);
        size.origin.x = BLANK_OFFSET_X;
        size.origin.y = BLANK_OFFSET_Y;
        CGContextDrawImage(drawContext, size, blankGraphic);
    }
    
    // Draw Time
    size.size.width = FONT_LARGE_WIDTH;
    size.size.height = FONT_LARGE_HEIGHT;
    size.origin.y = FONT_LARGE_Y_OFFSET;
    if ((timeDigit0 >= 0) && (timeDigit0 <= 9)) {
        size.origin.x = FONT_LARGE_X0_OFFSET;
        CGContextDrawImage(drawContext, size, [self largeHelper:timeDigit0]);
    }
    if ((timeDigit1 >= 0) && (timeDigit1 <= 9)) {
        size.origin.x = FONT_LARGE_X1_OFFSET;
        CGContextDrawImage(drawContext, size, [self largeHelper:timeDigit1]);
    }
    if ((timeDigit2 >= 0) && (timeDigit2 <= 9)) {
        size.origin.x = FONT_LARGE_X2_OFFSET;
        CGContextDrawImage(drawContext, size, [self largeHelper:timeDigit2]);
    }
    if ((timeDigit3 >= 0) && (timeDigit3 <= 9)) {
        size.origin.x = FONT_LARGE_X3_OFFSET;
        CGContextDrawImage(drawContext, size, [self largeHelper:timeDigit3]);
    }
    if (militaryTime == YES) {
        if ((timeDigit4 >= 0) && (timeDigit4 <= 9)) {
            size.origin.x = FONT_LARGE_X4_OFFSET;
            CGContextDrawImage(drawContext, size, [self largeHelper:timeDigit4]);
        }
        if ((timeDigit5 >= 0) && (timeDigit5 <= 9)) {
            size.origin.x = FONT_LARGE_X5_OFFSET;
            CGContextDrawImage(drawContext, size, [self largeHelper:timeDigit5]);
        }
    } else {
        // Draw AM/PM marker
        size.size.width = FONT_TIME_WIDTH;
        size.size.height = FONT_TIME_HEIGHT;
        size.origin.x = 36;
        size.origin.y = 63;
        CGContextDrawImage(drawContext, size, isAfternoon ? fontPM : fontAM);
    }
    
    // Draw dots between hours, minutes and seconds
    if (timeDots == YES) {
        size.size.width = CGImageGetWidth(dotLargeGraphic);
        size.size.height = CGImageGetHeight(dotLargeGraphic);
        size.origin.y = DOTS_TIME_Y_OFFSET;
        size.origin.x = DOTS_TIME_X0_OFFSET;
        CGContextDrawImage(drawContext, size, dotLargeGraphic);
        if (militaryTime == YES) {
            size.origin.x = DOTS_TIME_X1_OFFSET;
            CGContextDrawImage(drawContext, size, dotLargeGraphic);
        }
    }
    
    // Draw Alarm Graphic
    if (alarmSign == YES) {
        size.size.width = CGImageGetWidth(alarmGraphic);
        size.size.height = CGImageGetHeight(alarmGraphic);
        size.origin.x = ALARM_X_OFFSET;
        size.origin.y = ALARM_Y_OFFSET;
        CGContextDrawImage(drawContext, size, alarmGraphic);
    }
    
    // Draw dots between alarm hours and minutes
    if (alarmDots == YES) {
        size.size.width = CGImageGetWidth(dotSmallGraphic);
        size.size.height = CGImageGetHeight(dotSmallGraphic);
        size.origin.x = DOTS_ALARM_X_OFFSET;
        size.origin.y = DOTS_ALARM_Y_OFFSET;
        CGContextDrawImage(drawContext, size, dotSmallGraphic);
    }
    
    // Draw Alarm Time
    size.size.width = FONT_SMALL_WIDTH;
    size.size.height = FONT_SMALL_HEIGHT;
    size.origin.y = FONT_SMALL_ALARM_Y_OFFSET;
    if ((alarmDigit0 >= 0) && (alarmDigit0 <= 9)) {
        size.origin.x = FONT_SMALL_ALARM_X0_OFFSET;
        CGContextDrawImage(drawContext, size, [self smallHelper:alarmDigit0]);
    }
    if ((alarmDigit1 >= 0) && (alarmDigit1 <= 9)) {
        size.origin.x = FONT_SMALL_ALARM_X1_OFFSET;
        CGContextDrawImage(drawContext, size, [self smallHelper:alarmDigit1]);
    }
    if ((alarmDigit2 >= 0) && (alarmDigit2 <= 9)) {
        size.origin.x = FONT_SMALL_ALARM_X2_OFFSET;
        CGContextDrawImage(drawContext, size, [self smallHelper:alarmDigit2]);
    }
    if ((alarmDigit3 >= 0) && (alarmDigit3 <= 9)) {
        size.origin.x = FONT_SMALL_ALARM_X3_OFFSET;
        CGContextDrawImage(drawContext, size, [self smallHelper:alarmDigit3]);
    }
    
    size.origin = NSZeroPoint;
    if (animState == 0) {
        // Draw Otacon
        size.size.width = CGImageGetWidth(otaconGraphic);
        size.size.height = CGImageGetHeight(otaconGraphic);
        size.origin.x = CGImageGetWidth(bubbleGraphic) + OTACON_0_X_OFFSET;
        CGContextDrawImage(drawContext, size, otaconGraphic);
    
        // Draw eyes
        size.size.width = CGImageGetWidth([self eyeHelper:eyeToDraw]);
        size.size.height = CGImageGetHeight([self eyeHelper:eyeToDraw]);
        size.origin.x = EYE_X_OFFSET;
        size.origin.y = EYE_Y_OFFSET;
        CGContextDrawImage(drawContext, size, [self eyeHelper:eyeToDraw]);
    } else if (animState == 1) {
        size.size.width = CGImageGetWidth(otacon1Graphic);
        size.size.height = CGImageGetHeight(otacon1Graphic);
        size.origin.x = CGImageGetWidth(bubbleGraphic) + OTACON_1_X_OFFSET;
        CGContextDrawImage(drawContext, size, otacon1Graphic);
    } else if (animState == 2) {
        size.size.width = CGImageGetWidth(otacon2Graphic);
        size.size.height = CGImageGetHeight(otacon2Graphic);
        size.origin.x = CGImageGetWidth(bubbleGraphic) + OTACON_2_X_OFFSET;
        CGContextDrawImage(drawContext, size, otacon2Graphic);
    } else {
        size.size.width = CGImageGetWidth(otacon3Graphic);
        size.size.height = CGImageGetHeight(otacon3Graphic);
        size.origin.x = CGImageGetWidth(bubbleGraphic) + OTACON_3_X_OFFSET;
        CGContextDrawImage(drawContext, size, otacon3Graphic);
        
    }
    
    // Render resulting canvas into bitmap
    CGImageRef drawnImage = CGBitmapContextCreateImage(drawContext);
    
    // Add Drop Shadow if required
    if (dropShadow == YES) {
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowOffset:NSMakeSize(DROP_SHADOW_OFFSET_VIS * [(MainWindow *)[view window] startScale], -DROP_SHADOW_OFFSET_VIS * [(MainWindow *)[view window] startScale])];
        [shadow setShadowBlurRadius:DROP_SHADOR_BLUR];
        [shadow setShadowColor:[NSColor colorWithCalibratedRed:DROP_SHADOW_RED green:DROP_SHADOW_GREEN blue:DROP_SHADOW_BLUE alpha:DROP_SHADOW_ALPHA]];
        [shadow set];
    }
    
    // Leave some space for the drop shadow
    NSRect bound = [view bounds];
    if (dropShadow == YES) {
        bound.size.width -= DROP_SHADOW_OFFSET * [(MainWindow *)[view window] startScale];
        bound.size.height -= DROP_SHADOW_OFFSET * [(MainWindow *)[view window] startScale];
        bound.origin.y += DROP_SHADOW_OFFSET * [(MainWindow *)[view window] startScale];
    }
    
    // Scale bitmap into the window
    NSImage *result = [[NSImage alloc] initWithCGImage:drawnImage size:fullSize];
    [result drawInRect:bound fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:NSImageInterpolationNone] forKey:NSImageHintInterpolation]];
    CGImageRelease(drawnImage);
}

@end
