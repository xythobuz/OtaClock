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
#define RESIZE_END 10
#define RESIZE_STEP 1

#define CONFIG_START_SCALE @"window_scale"
#define CONFIG_KEEP_POSITION @"keep_position"
#define CONFIG_KEEP_ON_TOP @"keep_on_top"
#define CONFIG_MILITARY_TIME @"military_time"
#define CONFIG_SHOW_DATE @"show_date"
#define CONFIG_ALARM_TIME @"alarm_time"
#define CONFIG_ALARM_MODE @"alarm_mode"
#define CONFIG_DROP_SHADOW @"drop_shadow"

#define MOUSE_CENTER_X 67
#define MOUSE_CENTER_Y 47

#define EYE_BLINK 0
#define EYE_TOP_RIGHT 4
#define EYE_TOP_LEFT 2
#define EYE_BOTTOM_RIGHT 3
#define EYE_BOTTOM_LEFT 1

#define MAX_BLINK_DELAY 5.0
#define UNBLINK_DELAY 0.1
#define TIME_KEEPING_DELAY 0.25

// The shadow is not properly recomputed if we don't do it multiple times
#define ANIMATION_SHADOW_HACK 3
#define ALARM_ANIMATION_DELAY (0.25 / ANIMATION_SHADOW_HACK)
#define ALARM_ANIMATION_DELAY_END 3.0

@interface MainWindow ()

@property (assign) NSSize defaultSize;
@property (assign) NSInteger lastEyeState;
@property (assign) BOOL currentlyBlinking, showDate;

@property (weak) IBOutlet MainView *mainView;
@property (weak) IBOutlet NSDatePicker *alarmDatePicker;

@property (weak) IBOutlet NSMenuItem *lockPositionItem;
@property (weak) IBOutlet NSMenuItem *keepOnTopItem;
@property (weak) IBOutlet NSMenuItem *setAlarmItem;
@property (weak) IBOutlet NSMenuItem *showDateItem;
@property (weak) IBOutlet NSMenuItem *alarmModeItem;
@property (weak) IBOutlet NSMenuItem *alarmTextItem;
@property (weak) IBOutlet NSMenuItem *militaryTimeItem;
@property (weak) IBOutlet NSMenuItem *dropShadowItem;

@property (weak) IBOutlet NSMenuItem *changeSize1;
@property (weak) IBOutlet NSMenuItem *changeSize2;
@property (weak) IBOutlet NSMenuItem *changeSize3;
@property (weak) IBOutlet NSMenuItem *changeSize4;
@property (weak) IBOutlet NSMenuItem *changeSize5;
@property (weak) IBOutlet NSMenuItem *changeSize6;
@property (weak) IBOutlet NSMenuItem *changeSize7;
@property (weak) IBOutlet NSMenuItem *changeSize8;
@property (weak) IBOutlet NSMenuItem *changeSize9;
@property (weak) IBOutlet NSMenuItem *changeSize10;

@end

@implementation MainWindow

@synthesize dragStart;
@synthesize keepPosition;

@synthesize defaultSize;
@synthesize startScale;
@synthesize lastEyeState;
@synthesize currentlyBlinking, showDate;

- (id)initWithContentRect:(NSRect)contentRect
               styleMask:(NSUInteger)aStyle
                 backing:(NSBackingStoreType)bufferingType
                   defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setAlphaValue:1.0];
        [self setBackgroundColor:[NSColor clearColor]];
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
    if (startScale == 6) [self.changeSize6 setState:NSOnState];
    if (startScale == 7) [self.changeSize7 setState:NSOnState];
    if (startScale == 8) [self.changeSize8 setState:NSOnState];
    if (startScale == 9) [self.changeSize9 setState:NSOnState];
    if (startScale == 10) [self.changeSize10 setState:NSOnState];
    
    [[self.mainView render] drawWithEye:lastEyeState]; // Initialize render image
    [self unblink]; // Schedule next blinking
    
    // Start time keeping
    [self updateTime:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // load alarm date
    if ([defaults objectForKey:CONFIG_ALARM_TIME] == nil) {
        self.alarmDatePicker.dateValue = [NSDate date];
    } else {
        self.alarmDatePicker.dateValue = [defaults objectForKey:CONFIG_ALARM_TIME];
    }
    self.setAlarmItem.view = self.alarmDatePicker;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.alarmDatePicker.dateValue];
    [self.alarmTextItem setTitle:[NSString stringWithFormat:@"%02ld:%02ld", (long)[components hour], (long)[components minute]]];
    
    // load show date state
    if ([defaults objectForKey:CONFIG_SHOW_DATE] == nil) {
        showDate = YES;
    } else {
        showDate = [defaults boolForKey:CONFIG_SHOW_DATE];
    }
    if (showDate == YES) {
        self.showDateItem.state = NSOnState;
    } else {
        self.showDateItem.state = NSOffState;
    }
    
    // load alarm mode state
    if ([defaults objectForKey:CONFIG_ALARM_MODE] != nil) {
        if ([defaults boolForKey:CONFIG_ALARM_MODE] == YES) {
            [self.alarmModeItem setState:NSOnState];
            [[self.mainView render] drawAlarmDate:self.alarmDatePicker.dateValue];
        }
    }
    
    // load military time state
    if ([defaults objectForKey:CONFIG_MILITARY_TIME] == nil) {
        [self.militaryTimeItem setState:NSOnState];
        [[self.mainView render] drawMilitaryTime:YES];
    } else {
        if ([defaults boolForKey:CONFIG_MILITARY_TIME]) {
            [self.militaryTimeItem setState:NSOnState];
            [[self.mainView render] drawMilitaryTime:YES];
        } else {
            [[self.mainView render] drawMilitaryTime:NO];
        }
    }
    
    // load drop shadow state
    if ([defaults objectForKey:CONFIG_DROP_SHADOW] != nil) {
        if ([defaults boolForKey:CONFIG_DROP_SHADOW]) {
            [[self.mainView render] drawDropShadow:YES];
            [self.dropShadowItem setState:NSOnState];
            
            // increase window size
            frame.size.width += DROP_SHADOW_OFFSET * startScale;
            frame.size.height += DROP_SHADOW_OFFSET * startScale;
            frame.origin.y -= DROP_SHADOW_OFFSET * startScale;
        }
    }
    
    [[self.mainView render] drawDate:showDate];
    
    [self setFrame:frame display:YES];
}

- (IBAction)toggleDropShadow:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.dropShadowItem.state == NSOnState) {
        // Turn off drop shadow
        [self.dropShadowItem setState:NSOffState];
        [[self.mainView render] drawDropShadow:NO];
        [defaults setBool:NO forKey:CONFIG_DROP_SHADOW];
        
        // decrease window size
        NSRect rect = [self frame];
        rect.size = defaultSize;
        rect.size.width *= startScale;
        rect.size.height *= startScale;
        rect.origin.y += DROP_SHADOW_OFFSET * startScale;
        [self setFrame:rect display:YES];
    } else {
        // Turn on drop shadow
        [self.dropShadowItem setState:NSOnState];
        [[self.mainView render] drawDropShadow:YES];
        [defaults setBool:YES forKey:CONFIG_DROP_SHADOW];
        
        // increase window size
        NSRect rect = [self frame];
        rect.size.width += DROP_SHADOW_OFFSET * startScale;
        rect.size.height += DROP_SHADOW_OFFSET * startScale;
        rect.origin.y -= DROP_SHADOW_OFFSET * startScale;
        [self setFrame:rect display:YES];
    }
    
    [defaults synchronize];
    self.mainView.needsDisplay = YES;
}

- (IBAction)toggleMilitaryTime:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.militaryTimeItem.state == NSOnState) {
        // Turn off military time
        [self.militaryTimeItem setState:NSOffState];
        [[self.mainView render] drawMilitaryTime:NO];
        [defaults setBool:NO forKey:CONFIG_MILITARY_TIME];
    } else {
        // Turn on military time
        [self.militaryTimeItem setState:NSOnState];
        [[self.mainView render] drawMilitaryTime:YES];
        [defaults setBool:YES forKey:CONFIG_MILITARY_TIME];
    }
    
    [defaults synchronize];
    self.mainView.needsDisplay = YES;
}

- (IBAction)toggleAlarm:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.alarmModeItem.state == NSOnState) {
        // Turn off alarm
        [self.alarmModeItem setState:NSOffState];
        [[self.mainView render] drawAlarmDate:nil];
        [defaults setBool:NO forKey:CONFIG_ALARM_MODE];
    } else {
        // Turn on alarm
        [self.alarmModeItem setState:NSOnState];
        [[self.mainView render] drawAlarmDate:self.alarmDatePicker.dateValue];
        [defaults setBool:YES forKey:CONFIG_ALARM_MODE];
    }
    
    [defaults synchronize];
    self.mainView.needsDisplay = YES;
}

- (void)drawAnimation:(NSNumber *)anim {
    if ([anim integerValue] > (3 * ANIMATION_SHADOW_HACK)) {
        [[self.mainView render] drawAnimation:0]; // reset
    } else {
        [[self.mainView render] drawAnimation:([anim integerValue] / ANIMATION_SHADOW_HACK)];
    }
    
    if ([anim integerValue] < (3 * ANIMATION_SHADOW_HACK)) {
        [self performSelector:@selector(drawAnimation:) withObject:[NSNumber numberWithInteger:([anim integerValue] + 1)] afterDelay:ALARM_ANIMATION_DELAY];
    } else if ([anim integerValue] < (4 * ANIMATION_SHADOW_HACK)) {
        [self performSelector:@selector(drawAnimation:) withObject:[NSNumber numberWithInteger:([anim integerValue] + 1)] afterDelay:ALARM_ANIMATION_DELAY_END];
    }
    
    [self invalidateShadow];
    self.mainView.needsDisplay = YES;
}

- (void)updateTime:(id)sender {
    [self performSelector:@selector(updateTime:) withObject:nil afterDelay:TIME_KEEPING_DELAY];
    
    // Check if a second went by
    NSDate *now = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    static NSInteger lastSec = -1;
    if (lastSec == [components second]) {
        return;
    }
    lastSec = [components second];
    
    [[self.mainView render] drawWithDate:now];
    [[self.mainView render] blinkDots];
    
    if (self.alarmModeItem.state == NSOnState) {
        NSDateComponents *alarmComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.alarmDatePicker.dateValue];
        if (([components minute] == [alarmComponents minute]) && ([components hour] == [alarmComponents hour]) && ([components second] == 0)) {
            NSLog(@"Alarm time reached! (%02ld:%02ld)", (long)[alarmComponents hour], (long)[alarmComponents minute]);
            [self drawAnimation:[NSNumber numberWithInteger:1]];
        }
    }
    
    self.mainView.needsDisplay = YES;
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

- (IBAction)alarmDateSelected:(id)sender {
    // Update text representation
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.alarmDatePicker.dateValue];
    [self.alarmTextItem setTitle:[NSString stringWithFormat:@"%02ld:%02ld", (long)[components hour], (long)[components minute]]];
    
    if (self.alarmModeItem.state == NSOnState) {
        [[self.mainView render] drawAlarmDate:self.alarmDatePicker.dateValue];
        self.mainView.needsDisplay = YES;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.alarmDatePicker.dateValue forKey:CONFIG_ALARM_TIME];
    [defaults synchronize];
}

- (IBAction)showDate:(id)sender {
    if (showDate == YES) {
        showDate = NO;
        self.showDateItem.state = NSOffState;
    } else {
        showDate = YES;
        self.showDateItem.state = NSOnState;
    }
    [[self.mainView render] drawDate:showDate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:showDate forKey:CONFIG_SHOW_DATE];
    [defaults synchronize];
}

- (IBAction)changeSize:(NSMenuItem *)sender {
    NSRect frame = [self frame];
    
    [self.changeSize1 setState:NSOffState];
    [self.changeSize2 setState:NSOffState];
    [self.changeSize3 setState:NSOffState];
    [self.changeSize4 setState:NSOffState];
    [self.changeSize5 setState:NSOffState];
    [self.changeSize6 setState:NSOffState];
    [self.changeSize7 setState:NSOffState];
    [self.changeSize8 setState:NSOffState];
    [self.changeSize9 setState:NSOffState];
    [self.changeSize10 setState:NSOffState];
    
    BOOL found = NO;
    for (int i = RESIZE_START; i <= RESIZE_END; i += RESIZE_STEP) {
        NSString *title = [NSString stringWithFormat:@"x%d", i];
        if ([[sender title] isEqualToString:title]) {
            [sender setState:NSOnState];
            NSSize newSize = defaultSize;
            if (self.dropShadowItem.state == NSOnState) {
                newSize.width += DROP_SHADOW_OFFSET;
                newSize.height += DROP_SHADOW_OFFSET;
            }
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
