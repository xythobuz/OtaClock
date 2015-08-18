//
//  MainWindow.h
//  OtaClock
//
//  Created by Thomas Buck on 16.08.15.
//  Copyright (c) 2015 xythobuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindow : NSWindow

- (void)setDefaultBackgroundSize:(NSSize)size;

@property (assign) NSPoint dragStart;
@property (assign) BOOL keepPosition;
@property (assign) NSInteger startScale;

@end
