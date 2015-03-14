//
//  AppDelegate.h
//  Boot2Docker Status
//
//  Created by Nicholas Gartmann on 3/14/15.
//  Copyright (c) 2015 Nicholas Gartmann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LaunchAtLoginController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSButton *launchOnLoginBox;
@property (weak) IBOutlet NSMenu *statusMenu;

@end