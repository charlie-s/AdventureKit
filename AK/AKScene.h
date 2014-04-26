
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

#import "HUMAStarPathfinder.h"

@class JSTileMap;
@class HUMAStarPathfinder;
@class AKSprite;

@interface AKScene : SKScene <HUMAStarPathfinderDelegate>

-(void)loadScreenNumber:(int)number;
-(JSTileMap*)getTileMap;

@property NSInteger *cursorWait;
@property NSString *cursorActiveImage;
@property (nonatomic) AKSprite *hero;
@property (strong, nonatomic) JSTileMap* tileMap;
@property (nonatomic, strong) HUMAStarPathfinder *pathfinder;

@end
