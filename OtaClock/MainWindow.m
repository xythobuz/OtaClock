//
//  MainWindow.m
//  OtaClock
//
//  Created by Thomas Buck on 16.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "MainView.h"
#import "MainWindow.h"

#define RESIZE_START 1
#define RESIZE_END 5
#define RESIZE_STEP 1

#define CONFIG_START_SCALE @"window_scale"
#define CONFIG_KEEP_POSITION @"keep_position"
#define CONFIG_KEEP_ON_TOP @"keep_on_top"

#define MOUSE_CENTER_X 67
#define MOUSE_CENTER_Y 47

#define EYE_BLINK 0
#define EYE_TOP_RIGHT 4
#define EYE_TOP_LEFT 2
#define EYE_BOTTOM_RIGHT 3
#define EYE_BOTTOM_LEFT 1

#define MAX_BLINK_DELAY 5.0
#define UNBLINK_DELAY 0.1

@interface MainWindow ()

@property (assign) NSSize defaultSize;
@property (assign) NSInteger startScale;
@property (assign) NSInteger lastEyeState;
@property (assign) BOOL currentlyBlinking;

@property (weak) IBOutlet MainView *mainView;

@property (weak) IBOutlet NSMenuItem *lockPositionItem;
@property (weak) IBOutlet NSMenuItem *keepOnTopItem;

@property (weak) IBOutlet NSMenuItem *changeSize1;
@property (weak) IBOutlet NSMenuItem *changeSize2;
@property (weak) IBOutlet NSMenuItem *changeSize3;
@property (weak) IBOutlet NSMenuItem *changeSize4;
@property (weak) IBOutlet NSMenuItem *changeSize5;

@end

@implementation MainWindow

@synthesize dragStart;
@synthesize keepPosition;

@synthesize defaultSize;
@synthesize startScale;
@synthesize lastEyeState;
@synthesize currentlyBlinking;

- (id)initWithContentRect:(NSRect)contentRect
               styleMask:(NSUInteger)aStyle
                 backing:(NSBackingStoreType)bufferingType
                   defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        lastEyeState = EYE_TOP_LEFT;
        currentlyBlinking = NO;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // load and see if window should be kept on top
        if ([defaults objectForKey:CONFIG_KEEP_ON_TOP] != nil) {
            if ([defaults boolForKey:CONFIG_KEEP_ON_TOP]) {
                [self setLevel:NSFloatingWindowLevel];
            }
        }
        
        // load and see if window pos should be fixed
        if ([defaults objectForKey:CONFIG_KEEP_POSITION] == nil) {
            keepPosition = NO;
        } else {
            keepPosition = [defaults boolForKey:CONFIG_KEEP_POSITION];
        }
        
        // load window scale factor
        if ([defaults objectForKey:CONFIG_START_SCALE] == nil) {
            startScale = 1;
        } else {
            startScale = [defaults integerForKey:CONFIG_START_SCALE];
        }
    }
    
    [self setAcceptsMouseMovedEvents:YES];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent *mouseMovedEvent) { [self mouseMoved:mouseMovedEvent]; }];
    
    return self;
}

- (void)setDefaultBackgroundSize:(NSSize)size {
    defaultSize = size;
    NSRect frame = [self frame];
    frame.size = defaultSize;
    
    frame.size.width *= startScale;
    frame.size.height *= startScale;
    
    // We need to do all initialization of view state in here, because they are not ready in init
    if (keepPosition) [self.lockPositionItem setState:NSOnState];
    if ([self level] == NSFloatingWindowLevel) [self.keepOnTopItem setState:NSOnState];
    if (startScale == 1) [self.changeSize1 setState:NSOnState];
    if (startScale == 2) [self.changeSize2 setState:NSOnState];
    if (startScale == 3) [self.changeSize3 setState:NSOnState];
    if (startScale == 4) [self.changeSize4 setState:NSOnState];
    if (startScale == 5) [self.changeSize5 setState:NSOnState];
    
    [[self.mainView render] drawWithEye:lastEyeState]; // Initialize render image
    [self unblink]; // Schedule next blinking
    
    // Start time keeping
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [self updateTime:nil];
    
    [self setFrame:frame display:YES];
}

- (void)updateTime:(id)sender {
    //[[self.mainView render] drawWithDate:[NSDate date]];
    //self.mainView.needsDisplay = YES;
}

- (void)blink {
    if (currentlyBlinking == NO) {
        currentlyBlinking = YES;
        [[self.mainView render] drawWithEye:EYE_BLINK];
        self.mainView.needsDisplay = YES;
    }
    
    [self performSelector:@selector(unblink) withObject:nil afterDelay:UNBLINK_DELAY];
}

- (void)unblink {
    if (currentlyBlinking == YES) {
        currentlyBlinking = NO;
        [[self.mainView render] drawWithEye:lastEyeState];
        self.mainView.needsDisplay = YES;
    }
    
    [self performSelector:@selector(blink) withObject:nil afterDelay:(((float)rand() / RAND_MAX) * MAX_BLINK_DELAY)];
}

- (IBAction)changeSize:(NSMenuItem *)sender {
    NSRect frame = [self frame];
    
    [self.changeSize1 setState:NSOffState];
    [self.changeSize2 setState:NSOffState];
    [self.changeSize3 setState:NSOffState];
    [self.changeSize4 setState:NSOffState];
    [self.changeSize5 setState:NSOffState];
    
    BOOL found = NO;
    for (int i = RESIZE_START; i <= RESIZE_END; i += RESIZE_STEP) {
        NSString *title = [NSString stringWithFormat:@"%dx", i];
        if ([[sender title] isEqualToString:title]) {
            [sender setState:NSOnState];
            NSSize newSize = defaultSize;
            newSize.height *= i;
            newSize.width *= i;
            frame.size = newSize;
            found = YES;
            startScale = i;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:i forKey:CONFIG_START_SCALE];
            [defaults synchronize];
            
            break;
        }
    }
    
    if (found == NO) {
        NSLog(@"Unknown changeSize sender: %@", sender);
    } else {
        [self setFrame:frame display:YES];
    }
}

- (IBAction)lockPosition:(NSMenuItem *)sender {
    BOOL state = [sender state];
    if (state == NSOffState) {
        // Lock position
        state = NSOnState;
        [sender setState:state];
        self.keepPosition = YES;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:CONFIG_KEEP_POSITION];
        [defaults synchronize];
    } else {
        // Unlock position
        state = NSOffState;
        [sender setState:state];
        self.keepPosition = NO;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:CONFIG_KEEP_POSITION];
        [defaults synchronize];
    }
}

- (IBAction)keepOnTop:(NSMenuItem *)sender {
    BOOL state = [sender state];
    if (state == NSOffState) {
        // Keep window on top
        state = NSOnState;
        [sender setState:state];
        [self setLevel:NSFloatingWindowLevel];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:CONFIG_KEEP_ON_TOP];
        [defaults synchronize];
    } else {
        // Don't keep window on top
        state = NSOffState;
        [sender setState:state];
        [self setLevel:NSNormalWindowLevel];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:CONFIG_KEEP_ON_TOP];
        [defaults synchronize];
    }
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    dragStart = [theEvent locationInWindow];
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

- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint mousePoint = [NSEvent mouseLocation];
    mousePoint.x -= [self frame].origin.x;
    mousePoint.y -= [self frame].origin.y;
    
    BOOL top = (mousePoint.y > (MOUSE_CENTER_Y * startScale));
    BOOL right = (mousePoint.x > (MOUSE_CENTER_X * startScale));
    
    NSInteger eyeState = EYE_BOTTOM_LEFT;
    if (top && right) {
        eyeState = EYE_TOP_RIGHT;
    } else if (top && (!right)) {
        eyeState = EYE_TOP_LEFT;
    } else if ((!top) && right) {
        eyeState = EYE_BOTTOM_RIGHT;
    }
    
    if (eyeState != lastEyeState) {
        lastEyeState = eyeState;
        if (currentlyBlinking == NO) {
            [[self.mainView render] drawWithEye:lastEyeState];
            self.mainView.needsDisplay = YES;
        }
    }
}

@end
