
#import "AKAppDelegate.h"
#import "AKScene.h"

@implementation AKAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Load our scene controller.
    SKScene *scene = [AKScene sceneWithSize:CGSizeMake(960, 540)];

    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
