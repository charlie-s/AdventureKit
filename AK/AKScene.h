
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

#import "AKSprite.h"
#import "JSTileMap.h"
#import "HUMAStarPathfinder.h"

@class JSTileMap;

@interface AKScene : SKScene <HUMAStarPathfinderDelegate>

-(void)loadSceneNumber:(int)number;

@property (nonatomic) AKSprite *hero;

@property NSInteger *cursorWait;
@property NSString *cursorActiveImage;

@property (strong, nonatomic) JSTileMap* tileMap;
@property (nonatomic, strong) HUMAStarPathfinder *pathfinder;

@end
