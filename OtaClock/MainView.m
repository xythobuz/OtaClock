//
//  MainView.m
//  OtaClock
//
//  Created by Thomas Buck on 16.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "Render.h"
#import "MainWindow.h"
#import "MainView.h"

@interface MainView ()

@end

@implementation MainView

@synthesize render;

-(void)awakeFromNib {
    render = [[Render alloc] initWithParent:self];
    [(MainWindow*)[self window] setDefaultBackgroundSize:[render baseSize]]; // Set window to a useful default size
}

-(void)drawRect:(NSRect)dirtyRect {
    // Clear background
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    [render drawInto:self]; // Draw composite image
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    // This is required so we get mouse events even if we don't have focus
    // (needed to allow dragging the window without focus)
    return YES;
}

@end
