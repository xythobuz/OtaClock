//
//  MainWindow.m
//  OtaClock
//
//  Created by Thomas Buck on 16.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "MainWindow.h"

@interface MainWindow ()

@property (assign) NSSize defaultSize;

@end

@implementation MainWindow

@synthesize dragStart;
@synthesize keepPosition;
@synthesize defaultSize;

- (id)initWithContentRect:(NSRect)contentRect
               styleMask:(NSUInteger)aStyle
                 backing:(NSBackingStoreType)bufferingType
                   defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        
        // load and see if window should be kept on top
        // also set proper button state
        //[self setLevel:NSFloatingWindowLevel];
        
        // load and see if window pos should be fixed
        // also set proper button state
        self.keepPosition = NO;
    }
    return self;
}

- (void)setDefaultBackgroundSize:(NSSize)size {
    defaultSize = size;
    NSRect frame = [self frame];
    frame.size = defaultSize;
    [self setFrame:frame display:YES];
}

- (IBAction)changeSize:(NSMenuItem *)sender {
    NSRect frame = [self frame];
    
    if ([[sender title] isEqualToString:@"1x"]) {
        frame.size = defaultSize;
    } else if ([[sender title] isEqualToString:@"2x"]) {
        NSSize newSize = defaultSize;
        newSize.height *= 2;
        newSize.width *= 2;
        frame.size = newSize;
    } else {
        NSLog(@"Unknown changeSize sender: %@", sender);
        return;
    }
    
    [self setFrame:frame display:YES];
}

- (IBAction)lockPosition:(NSMenuItem *)sender {
    BOOL state = [sender state];
    if (state == NSOffState) {
        // Lock position
        state = NSOnState;
        [sender setState:state];
        self.keepPosition = YES;
        // store...
    } else {
        // Unlock position
        state = NSOffState;
        [sender setState:state];
        self.keepPosition = NO;
        // store...
    }
}

- (IBAction)keepOnTop:(NSMenuItem *)sender {
    BOOL state = [sender state];
    if (state == NSOffState) {
        // Keep window on top
        state = NSOnState;
        [sender setState:state];
        [self setLevel:NSFloatingWindowLevel];
        // store...
    } else {
        // Don't keep window on top
        state = NSOffState;
        [sender setState:state];
        [self setLevel:NSNormalWindowLevel];
        // store...
    }
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    self.dragStart = [theEvent locationInWindow];
    
    NSLog(@"Mouse at %f %f", self.dragStart.x, self.dragStart.y);
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;
    
    if (self.keepPosition == NO) {
        NSPoint currentLocation = [theEvent locationInWindow];
        newOrigin.x += (currentLocation.x - dragStart.x);
        newOrigin.y += (currentLocation.y - dragStart.y);
    
        if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
            newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
        }
    
        [self setFrameOrigin:newOrigin];
    }
}

@end
