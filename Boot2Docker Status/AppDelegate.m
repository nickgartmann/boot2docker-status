//
//  AppDelegate.m
//  Boot2Docker Status
//
//  Created by Nicholas Gartmann on 3/14/15.
//  Copyright (c) 2015 Nicholas Gartmann. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()
@property (weak) NSUserDefaults *standardUserDefaults;
@property (weak) IBOutlet NSWindow *window;
@property BOOL haveRequestedStateChange;
@property BOOL darkMode;
@end




@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _haveRequestedStateChange = NO;
    
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	_darkMode = NO;
    NSString *osxMode = [_standardUserDefaults stringForKey:@"AppleInterfaceStyle"];
	if ([osxMode isEqualToString:@"Dark"] || [osxMode isEqualToString:@"dark"]) {
		_darkMode = YES;
	}

    [_standardUserDefaults registerDefaults:@{
        @"DisplayWindowOnStartup": @YES
    }];
    
    // The text that will be shown in the menu bar
    _statusItem.title = @"";
    
    if([self isBoot2DockerRunning]) {
    } else {
		_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor greenColor]];
		_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor redColor]];
    }
    
    // The image gets a blue background when the item is selected
    _statusItem.highlightMode = NO;
    
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [_launchOnLoginBox setState:launch];
    
    [_showWindowOnStartupBox setState:[self shouldDisplayWindowOnBoot]];
    
    [_statusItem setTarget:self];
    [_statusItem setAction:@selector(toggleBoot2Docker:)];
    
    if([self shouldDisplayWindowOnBoot]) {
        [self openWindow:self];
    }
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(renderIcon:)
                                   userInfo:nil
                                    repeats:YES];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)toggleAutoStart:(id)sender {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:[sender state]];
}

- (void)openMenu {
    [self.statusItem setHighlightMode:YES];
    [_statusItem popUpStatusItemMenu:_statusMenu];
}

- (IBAction)openWindow:(id)sender {
    [self.statusItem setHighlightMode:NO];
    [_window setIsVisible:TRUE];
    [_window makeKeyAndOrderFront:sender];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate: nil];
}

- (IBAction)close:(id)sender {
    [_window close];
}

- (IBAction)toggleShowWindowOnBoot:(id)sender {
    if (_standardUserDefaults) [_standardUserDefaults setBool:[sender state] forKey:@"DisplayWindowOnStartup"];
    [_standardUserDefaults synchronize];
}

- (BOOL)shouldDisplayWindowOnBoot {
    BOOL val = YES;
    if (_standardUserDefaults) val = [_standardUserDefaults boolForKey:@"DisplayWindowOnStartup"];
    return val;
}

- (void)toggleBoot2Docker:(id)sender {
    if([NSEvent modifierFlags] & NSCommandKeyMask) {
        [self.statusItem setHighlightMode:YES];
        [self openMenu];
    } else {
        if([self isBoot2DockerRunning]) {
			_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor colorWithRed:1 green:.6 blue:0 alpha:1]];
            [self stopBoot2Docker];
        } else {
			_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor colorWithRed:1 green:.8 blue:0 alpha:1]];
            [self startBoot2Docker];
        }
    }
}

- (void)renderIcon:(id)sender {
    if(!_haveRequestedStateChange) {
        if([self isBoot2DockerRunning]) {
			_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor greenColor]];
        } else {
			_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor redColor]];
        }
    }
}

- (BOOL)isBoot2DockerRunning {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", @"/usr/local/bin/boot2docker status"]];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    
    NSFileHandle *fOut;
    fOut = [pipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data = [fOut readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [output containsString:@"running"];
}

- (void)startBoot2Docker {
    _haveRequestedStateChange = YES;
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", @"/usr/local/bin/boot2docker up"]];
    
    [task setTerminationHandler:^(NSTask *t) {
        _haveRequestedStateChange = NO;
		_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor greenColor]];
    }];
    
    [task launch];
}

- (void)stopBoot2Docker {
    _haveRequestedStateChange = YES;
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", @"/usr/local/bin/boot2docker down"]];
    
    [task setTerminationHandler:^(NSTask *t) {
        _haveRequestedStateChange = NO;
		_statusItem.image = [self _iconWithNotificationBubbleWithColor:[NSColor redColor]];
    }];
    
    [task launch];
}

- (NSImage*)_iconWithNotificationBubbleWithColor:(NSColor*)color {
	NSImage* image = [(_darkMode ? [NSImage imageNamed:@"docker-dark"] : [NSImage imageNamed:@"docker"]) copy];

	NSBezierPath* notificationBubble = [NSBezierPath bezierPath];
	[notificationBubble appendBezierPathWithOvalInRect:NSMakeRect(image.size.width-10, 1, 6, 6)];

	[image lockFocus];
	[color setFill];
	[notificationBubble fill];
	[image unlockFocus];

	return image;
}

@end
