
#import "AKSprite.h"
#import "AKScene.h"
#import "JSTileMap.h"
#import "HUMAStarPathfinder.h"

@implementation AKSprite
{
    AKScene *_scene;
    
    SKSpriteNode *_sprite;
    float _scaleRate;
    NSString *_scaleDirection;
    NSString *_facing;
    NSString *_walking;
    
    NSArray *_directions;
}

-(id)initIntoScene:(AKScene*)scene
{
    if(self = [super init]) {
        _scene = scene;
        
        // Load "still" atlas.
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"still"]];
        _sprite = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"s"]];

        _sprite.name = @"sprite";
        
        // Anchor our sprite at bottom center.
        _sprite.anchorPoint = CGPointMake(0.5,0.0);

        // Add nodes.
        [self addChild:_sprite];
        
        // Set directions.
//        _directions = @[@"n", @"ne", @"e", @"se", @"s", @"sw", @"w", @"nw"];
        _directions = @[@"e", @"w"];
    }
    
    return self;
}

/**
 * Set the scale rate and direction.
 */
-(void)setScaleRate:(float)rate direction:(NSString*)direction
{
    _scaleRate = rate;
    _scaleDirection = direction;
}

/**
 * Get the current sprite size.
 */
-(CGSize)getSize
{
    return _sprite.size;
}

/**
 * Get the current sprite position.
 */
-(CGPoint)getPosition
{
    return _sprite.position;
}

/**
 * Set the direction sprite is currently facing.
 */
-(void)setDirectionFacing:(NSString*)direction
{
    _facing = direction;
}

/**
 * Set the direction sprite is currently walking.
 */
-(void)setDirectionWalking:(NSString*)direction
{
    _walking = direction;
}

/**
 * Move sprite to point (not animated).
 */
-(void)moveTo:(CGPoint)point
{
    NSLog(@"AKSprite moveTo %@", NSStringFromPoint(point));
    [_sprite removeActionForKey: @"Move_Sprite"];
    [_sprite removeActionForKey: @"Move_Sprite_Animation"];
    _sprite.position = point;
}

/**
 * Generate an SKTextureAtlas object for the given direction.
 */
-(NSMutableArray*)loadAtlasFacing:(NSString*)direction
{
    // Create return array.
    NSMutableArray *frames = [NSMutableArray array];
    
    // Get atlas.
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"walk-%@", direction]];
    
    // For each atlas texture, add to frames array.
    for (int i=1; i <= atlas.textureNames.count; i++) {
        SKTexture *temp = [atlas textureNamed:[NSString stringWithFormat:@"%d", i]];
        [frames addObject:temp];
    }

    return frames;
}

/**
 * Walk sprite to point (animated).
 */
-(void)walkTo:(NSArray*)walkPath
{
    // Gather animation frame arrays.
    NSMutableDictionary *walkFramesets = [NSMutableDictionary dictionary];
    for (id object in _directions) {
        NSMutableArray *atlas = [self loadAtlasFacing:object];
        [walkFramesets setObject:atlas forKey:object];
    }
    
    // Create array to store all SKActions for this walk event.
    NSMutableArray *walkActions = [[NSMutableArray alloc] init];
    
    // Move our sprite.
    int i = 0;
    for (id object in walkPath) {
        
        // Create an array for the current point, in the event that the current point requires a direction change
        // which means multiple parallel SKActions will be run (moveTo and starting an animation).
        NSMutableArray *currentActions = [[NSMutableArray alloc] init];

        // Convert the current point string ({0, 0}) to a CGPoint.
        NSValue *currentPoint = object;
        CGPoint currentCGPoint = currentPoint.pointValue;
        
        // Build the SKAction to walk the sprite to the current point.
        SKAction *walkAction = [SKAction moveTo:currentCGPoint duration:0.1];
        [currentActions addObject:walkAction];
        
        // If we're past the first loop through walkPath, get the previous point to see if our direction has
        // changed; otherwise just use the sprite's starting position.
        CGPoint previousCGPoint = _sprite.position;
        if (i) {
            NSValue *previousPoint = walkPath[i - 1];
            previousCGPoint = previousPoint.pointValue;
        }
        
        // Determine if _scaleRate and _scaleDirection should alter the sprites size.
        // ...
        
        // Check for direction change.
        if (currentCGPoint.x > previousCGPoint.x && ![_walking isEqualToString:@"e"]) {
            [self setDirectionWalking:@"e"];
            [self setDirectionFacing:@"e"];
            
            NSMutableArray *walkFrames = [walkFramesets objectForKey:@"e"];

            // Add action to change direction. We do this in a block do that it doesn't block the queue of
            // subsequent paths from executing.
            SKAction *walkAnimate = [SKAction animateWithTextures:walkFrames timePerFrame:0.1f resize:NO restore:YES];
            SKAction *changeDirection = [SKAction runBlock:^{
                [_sprite runAction:[SKAction repeatActionForever:walkAnimate] withKey:@"Move_Sprite_Animation"];
            }];
            
            [currentActions addObject:changeDirection];
        }
        else if (currentCGPoint.x < previousCGPoint.x && ![_walking isEqualToString:@"w"]) {
            [self setDirectionWalking:@"w"];
            [self setDirectionFacing:@"w"];
            
            NSMutableArray *walkFrames = [walkFramesets objectForKey:@"w"];
            
            // Add action to change direction. We do this in a block do that it doesn't block the queue of
            // subsequent paths from executing.
            SKAction *walkAnimate = [SKAction animateWithTextures:walkFrames timePerFrame:0.1f resize:NO restore:YES];
            SKAction *changeDirection = [SKAction runBlock:^{
                [_sprite runAction:[SKAction repeatActionForever:walkAnimate] withKey:@"Move_Sprite_Animation"];
            }];
            
            [currentActions addObject:changeDirection];
        }
        
        // Listen for portal hit. If hit, send message to parent.

//        JSTileMap *tileMap = [_scene getTileMap];
//        TMXLayer *meta = [tileMap layerNamed:@"block"];
//        SKSpriteNode *tile = [meta tileAt:currentCGPoint];
//        NSLog(@"tile:%@", tile);
//        NSLog(@"%@", tile);
//        if (TRUE) {
//            NSLog(@"Portal hit!");
//            SKAction *portalHit = [SKAction runBlock:^{
//                [_scene loadSceneNumber:1];
//            }];
//            [currentActions addObject:portalHit];
//        }
        
        // Add to our array of walk SKAction's.
        [walkActions addObject:[SKAction group:currentActions]];
        
        i++;
    }
    
    // Stop the animation when we're all done.
    SKAction *stopWalkAction = [SKAction runBlock:^{
        [_sprite removeActionForKey: @"Move_Sprite_Animation"];
        [self setDirectionWalking:@""];
        
        // Update the "facing" direction.
        SKTextureAtlas *stillAtlas = [SKTextureAtlas atlasNamed:@"still"];
        SKTexture *temp = [stillAtlas textureNamed:_facing];
        _sprite.texture = temp;
    }];
    [walkActions addObject:stopWalkAction];
    
    // Run all actions!
    SKAction *sequence = [SKAction sequence:walkActions];

    [_sprite runAction:sequence withKey:@"Move_Sprite"];
}

@end