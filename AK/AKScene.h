
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

#import "AKSprite.h"

@interface AKScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) AKSprite *hero;

@property NSInteger *cursorWait;
@property NSString *cursorActiveImage;

@end
