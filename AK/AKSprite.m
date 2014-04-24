
#import "AKSprite.h"

@implementation AKSprite
{
    SKSpriteNode *_sprite;
    SKSpriteNode *_spriteFeet;
    NSString *_facing;
}

-(id)init
{
    if(self = [super init]) {
        _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"down-still.gif"];
        _sprite.name = @"sprite";
        
        // Anchor our sprite at bottom center.
        _sprite.anchorPoint = CGPointMake(0.5,0.0);
        
        // Add invisible node at sprite's feet for boundary detection.
        _spriteFeet = [SKSpriteNode node];
        _spriteFeet.name = @"spriteFeet";
        _spriteFeet.size = CGSizeMake(_sprite.size.width, _sprite.size.height * .1);
        _spriteFeet.color = [SKColor blueColor];
        _spriteFeet.anchorPoint = CGPointMake(0.5,0.0);

        // Add nodes.
        [self addChild:_sprite];
        [self addChild:_spriteFeet];
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
 * Set the direction our sprite is currently facing.
 */
-(void)setDirectionFacing:(NSString*)direction
{
    _facing = direction;
}

/**
 * Move sprite to point (not animated).
 */
-(void)moveTo:(CGPoint)point
{
    _sprite.position = point;
    _spriteFeet.position = point;
}

/**
 * Walk sprite to point (animated).
 */
-(void)walkTo:(NSArray*)walkPath
{
    // Build out SKTexture for left walk animation.
    NSMutableArray *walkLeftFrames = [NSMutableArray array];
    SKTextureAtlas *walkLeftAnimatedAtlas = [SKTextureAtlas atlasNamed:@"walk-left"];
    
    NSUInteger numImagesLeft = walkLeftAnimatedAtlas.textureNames.count;
    for (int i=1; i <= numImagesLeft; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [walkLeftAnimatedAtlas textureNamed:textureName];
        [walkLeftFrames addObject:temp];
    }

    // Build out SKTexture for right walk animation.
    NSMutableArray *walkRightFrames = [NSMutableArray array];
    SKTextureAtlas *walkRightAnimatedAtlas = [SKTextureAtlas atlasNamed:@"walk-right"];
    
    NSUInteger numImagesRight = walkRightAnimatedAtlas.textureNames.count;
    for (int i=1; i <= numImagesRight; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [walkRightAnimatedAtlas textureNamed:textureName];
        [walkRightFrames addObject:temp];
    }
    
    // Move our hero.
    NSMutableArray *walkActions = [[NSMutableArray alloc] init];
    int i = 0;
    for (id object in walkPath) {
        // Convert point string ({0, 0}) to CGPoint.
        NSValue *curPoint = object;
        CGPoint curCGPoint = curPoint.pointValue;
        
        // Get previous point, if it exists.
        CGPoint prevCGPoint = _sprite.position;
        if (i) {
            NSValue *prevPoint = walkPath[i - 1];
            prevCGPoint = prevPoint.pointValue;
        }
        
        // Set direction facing.
        if (curCGPoint.x > prevCGPoint.x && [_facing isEqualToString:@"left"]) {
            [self setDirectionFacing:@"right"];

            // Add action to change direction.
            SKAction *changeDir = [SKAction repeatActionForever:[SKAction animateWithTextures:walkRightFrames timePerFrame:0.1f resize:NO restore:YES]];
            [walkActions addObject:changeDir];
            
        } else if (curCGPoint.x < prevCGPoint.x && [_facing isEqualToString:@"right"]) {
            [self setDirectionFacing:@"left"];
            
            // Add action to change direction.
            SKAction *changeDir = [SKAction repeatActionForever:[SKAction animateWithTextures:walkLeftFrames timePerFrame:0.1f resize:NO restore:YES]];
            [walkActions addObject:changeDir];
        }
        
        // Build SKAction to walk hero to the current point.
        SKAction *walkAction = [SKAction moveTo:curCGPoint duration:0.1];
        
        // Add to our array of walk SKAction's.
        [walkActions addObject:walkAction];
        
        i++;
    }
    
    // Stop the animation when we're all done.
    SKAction *stopWalkAction = [SKAction runBlock:^{
        [_sprite removeActionForKey: @"Move_Hero_Animation"];

        // Update the "facing" direction.
        _sprite.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-still.gif", _facing]];
    }];
    [walkActions addObject:stopWalkAction];
    
    // Run all actions!
    SKAction *sequence = [SKAction sequence:walkActions];

    [_sprite runAction:sequence withKey:@"Move_Hero"];
    [_spriteFeet runAction:sequence withKey:@"Move_Hero_Feet"];
}

@end