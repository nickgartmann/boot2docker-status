//
//  AppDelegate.m
//  Boot2Docker Status
//
//  Created by Nicholas Gartmann on 3/14/15.
//  Copyright (c) 2015 Nicholas Gartmann. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // The text that will be shown in the menu bar
    _statusItem.title = @"";
    
    if([self isBoot2DockerRunning]) {
        _statusItem.image = [NSImage imageNamed:@"docker"];
    } else {
        _statusItem.image = [NSImage imageNamed:@"docker-alt"];
    }
    
    // The image gets a blue background when the item is selected
    _statusItem.highlightMode = NO;
    
    [_statusItem setTarget:self];
    [_statusItem setAction:@selector(toggleBoot2Docker:)];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openMenu:(id)sender {
    NSLog(@"HERE");
}

- (void)toggleBoot2Docker:(id)sender {
    _statusItem.image = [NSImage imageNamed:@"docker-loading"];
    if([self isBoot2DockerRunning]) {
        [self stopBoot2Docker];
    } else {
        [self startBoot2Docker];
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
