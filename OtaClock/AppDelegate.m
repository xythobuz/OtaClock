//
//  AppDelegate.m
//  OtaClock
//
//  Created by Thomas Buck on 16.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

@synthesize statusItem;
@synthesize mainMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create Status Bar Item
    /*
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.image = [NSImage imageNamed:@"Menu"];
    statusItem.highlightMode = YES;
    statusItem.menu = mainMenu; */ // Use same menu used for right-clicks
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Remove Status Bar Item
    //[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

@end
