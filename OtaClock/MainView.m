//
//  MainView.m
//  OtaClock
//
//  Created by Thomas Buck on 16.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "MainWindow.h"
#import "MainView.h"

#define BASE_IMAGE_RESIZE_FACTOR 0.2

@implementation MainView

@synthesize otaconImage;

-(void)awakeFromNib {
    NSLog(@"MainView:awakeFromNib %@ %@", self, [self window]);
    
    // Load background image
    self.otaconImage = [NSImage imageNamed:@"Otacon"];
    
    // Set window to a useful default size
    NSSize newSize = [otaconImage size];
    newSize.width *= BASE_IMAGE_RESIZE_FACTOR;
    newSize.height *= BASE_IMAGE_RESIZE_FACTOR;
    [(MainWindow*)[self window] setDefaultBackgroundSize:newSize];
}

-(void)drawRect:(NSRect)dirtyRect {
    // Clear background
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    
    // Draw main image into window bounds
    [otaconImage drawInRect:[self bounds]];
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    // This is required so we get mouse events even if we don't have focus
    // (needed to allow dragging the window without focus)
    return YES;
}

@end
