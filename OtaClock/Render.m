//
//  Render.m
//  OtaClock
//
//  Created by Thomas Buck on 17.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "Render.h"

#define FULL_IMAGE_WIDTH 86
#define FULL_IMAGE_HEIGHT 80
#define BUBBLE_Y_OFFSET 45
#define OTACON_X_OFFSET 1
#define EYE_X_OFFSET 60
#define EYE_Y_OFFSET 45

@interface Render ()

@property (assign) CGImageRef otaconGraphic;
@property (assign) CGImageRef bubbleGraphic;
@property (assign) CGImageRef eye0, eye1, eye2, eye3, eye4;

@property (assign) NSSize fullSize;
@property (assign) CGContextRef drawContext;

@end

@implementation Render

@synthesize otaconGraphic;
@synthesize bubbleGraphic;
@synthesize eye0, eye1, eye2, eye3, eye4;

@synthesize fullSize;
@synthesize drawContext;

- (CGImageRef)eyeHelper:(NSInteger)index {
    if (index == 0) return eye0;
    if (index == 1) return eye1;
    if (index == 2) return eye2;
    if (index == 3) return eye3;
    if (index == 4) return eye4;
    
    NSLog(@"Render:eyeHelper:%ld unknown index!", (long)index);
    return eye0;
}

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    NSImage *otaconImage = [NSImage imageNamed:@"otacon"];
    NSImage *bubbleImage = [NSImage imageNamed:@"bubble"];
    NSImage *eye0Image = [NSImage imageNamed:@"eyes_0"];
    NSImage *eye1Image = [NSImage imageNamed:@"eyes_1"];
    NSImage *eye2Image = [NSImage imageNamed:@"eyes_2"];
    NSImage *eye3Image = [NSImage imageNamed:@"eyes_3"];
    NSImage *eye4Image = [NSImage imageNamed:@"eyes_4"];
    
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithAttributes:nil];
    
    otaconGraphic = [otaconImage CGImageForProposedRect:nil context:context hints:nil];
    bubbleGraphic = [bubbleImage CGImageForProposedRect:nil context:context hints:nil];
    eye0 = [eye0Image CGImageForProposedRect:nil context:context hints:nil];
    eye1 = [eye1Image CGImageForProposedRect:nil context:context hints:nil];
    eye2 = [eye2Image CGImageForProposedRect:nil context:context hints:nil];
    eye3 = [eye3Image CGImageForProposedRect:nil context:context hints:nil];
    eye4 = [eye4Image CGImageForProposedRect:nil context:context hints:nil];
    
    fullSize.width = FULL_IMAGE_WIDTH;
    fullSize.height = FULL_IMAGE_HEIGHT;
    
    drawContext = CGBitmapContextCreate(NULL, fullSize.width, fullSize.height, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    
    return self;
}

- (NSSize)baseSize {
    return fullSize;
}

- (void)drawWith:(NSInteger)eyeIndex {
    CGRect size;
    
    // Clear entire canvas
    size.size = fullSize;
    size.origin = NSZeroPoint;
    CGContextClearRect(drawContext, size);
    
    // Draw Speech Bubble
    size.size.width = CGImageGetWidth(bubbleGraphic);
    size.size.height = CGImageGetHeight(bubbleGraphic);
    size.origin.y = BUBBLE_Y_OFFSET;
    CGContextDrawImage(drawContext, size, bubbleGraphic);
    
    // Draw Otacon
    size.size.width = CGImageGetWidth(otaconGraphic);
    size.size.height = CGImageGetHeight(otaconGraphic);
    size.origin = NSZeroPoint;
    size.origin.x = CGImageGetWidth(bubbleGraphic) + OTACON_X_OFFSET;
    CGContextDrawImage(drawContext, size, otaconGraphic);
    
    // Draw eyes
    size.size.width = CGImageGetWidth([self eyeHelper:eyeIndex]);
    size.size.height = CGImageGetHeight([self eyeHelper:eyeIndex]);
    size.origin.x = EYE_X_OFFSET;
    size.origin.y = EYE_Y_OFFSET;
    CGContextDrawImage(drawContext, size, [self eyeHelper:eyeIndex]);
}

- (void)drawInto:(NSView *)view {
    CGImageRef drawnImage = CGBitmapContextCreateImage(drawContext);
    NSImage *result = [[NSImage alloc] initWithCGImage:drawnImage size:fullSize];
    [result drawInRect:[view bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:NSImageInterpolationNone] forKey:NSImageHintInterpolation]];
}

@end
