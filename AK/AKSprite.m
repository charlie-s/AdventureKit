
#import "AKSprite.h"

@implementation AKSprite
{
    SKSpriteNode *_sprite;
    NSString *_facing;
    NSString *_walking;
}

-(id)init
{
    if(self = [super init]) {
        _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"down-still.gif"];
        _sprite.name = @"sprite";
        
        // Anchor our sprite at bottom center.
        _sprite.anchorPoint = CGPointMake(0.5,0.0);

        // Add nodes.
        [self addChild:_sprite];
    }
    
    return self;
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
    _sprite.position = point;
}

/**
 * Generate an SKTextureAtlas object for the given direction.
 */
-(NSMutableArray*)buildAtlasFacing:(NSString*)direction
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
    NSMutableArray *walkLeftFrames = [self buildAtlasFacing:@"left"];
    NSMutableArray *walkRightFrames = [self buildAtlasFacing:@"right"];
    
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
        
        // Check for direction change.
        if (currentCGPoint.x > previousCGPoint.x && ![_walking isEqualToString:@"right"]) {
            [self setDirectionWalking:@"right"];
            [self setDirectionFacing:@"right"];

            // Add action to change direction. We do this in a block do that it doesn't block the queue of
            // subsequent paths from executing.
            SKAction *walkAnimate = [SKAction animateWithTextures:walkRightFrames timePerFrame:0.1f resize:NO restore:YES];
            SKAction *changeDirection = [SKAction runBlock:^{
                [_sprite runAction:[SKAction repeatActionForever:walkAnimate] withKey:@"Move_Sprite_Animation"];
            }];
            
            [currentActions addObject:changeDirection];
        }
        else if (currentCGPoint.x < previousCGPoint.x && ![_walking isEqualToString:@"left"]) {
            [self setDirectionWalking:@"left"];
            [self setDirectionFacing:@"left"];
            
            // Add action to change direction. We do this in a block do that it doesn't block the queue of
            // subsequent paths from executing.
            SKAction *walkAnimate = [SKAction animateWithTextures:walkLeftFrames timePerFrame:0.1f resize:NO restore:YES];
            SKAction *changeDirection = [SKAction runBlock:^{
                [_sprite runAction:[SKAction repeatActionForever:walkAnimate] withKey:@"Move_Sprite_Animation"];
            }];
            
            [currentActions addObject:changeDirection];
        }
        
        // Add to our array of walk SKAction's.
        [walkActions addObject:[SKAction group:currentActions]];
        
        i++;
    }
    
    // Stop the animation when we're all done.
    SKAction *stopWalkAction = [SKAction runBlock:^{
        [_sprite removeActionForKey: @"Move_Sprite_Animation"];
        [self setDirectionWalking:@""];

        // Update the "facing" direction.
        _sprite.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-still.gif", _facing]];
    }];
    [walkActions addObject:stopWalkAction];
    
    // Run all actions!
    SKAction *sequence = [SKAction sequence:walkActions];

    [_sprite runAction:sequence withKey:@"Move_Sprite"];
}

@end