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
@end




@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [_standardUserDefaults registerDefaults:@{
        @"DisplayWindowOnStartup": @YES
    }];
    
    // The text that will be shown in the menu bar
    _statusItem.title = @"";
    
    if([self isBoot2DockerRunning]) {
        _statusItem.image = [NSImage imageNamed:@"docker"];
    } else {
        _statusItem.image = [NSImage imageNamed:@"docker-alt"];
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
        _statusItem.image = [NSImage imageNamed:@"docker-loading"];
        if([self isBoot2DockerRunning]) {
            [self stopBoot2Docker];
        } else {
            [self startBoot2Docker];
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
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", @"/usr/local/bin/boot2docker up"]];
    
    [task setTerminationHandler:^(NSTask *t) {
        _statusItem.image = [NSImage imageNamed:@"docker"];
    }];
    
    [task launch];
}

- (void)stopBoot2Docker {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", @"/usr/local/bin/boot2docker down"]];
    
    [task setTerminationHandler:^(NSTask *t) {
        _statusItem.image = [NSImage imageNamed:@"docker-alt"];
    }];
    
    [task launch];
}


@end
