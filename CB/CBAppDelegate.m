//
//  CBAppDelegate.m
//  CB
//
//  Created by Charlie Schliesser on 4/17/14.
//  Copyright (c) 2014 Acme Inc. All rights reserved.
//

#import "CBAppDelegate.h"
#import "CBMyScene.h"

@implementation CBAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* Pick a size for the scene */
    SKScene *scene = [CBMyScene sceneWithSize:CGSizeMake(1024, 768)];

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
