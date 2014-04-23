
#import "AKSprite.h"

static const uint32_t playerCategory = 0x1 << 0;
static const uint32_t blockCategory = 0x1 << 1;
static const uint32_t playerFeetCategory = 0x1 << 2;
static const uint32_t blockFeetCategory = 0x1 << 3;

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
        _spriteFeet.color = [SKColor redColor];
        _spriteFeet.anchorPoint = CGPointMake(0.5,0.0);

        // Add nodes.
        [self addChild:_sprite];
        [self addChild:_spriteFeet];
    }
    
    return self;
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
-(void)walkTo:(CGPoint)location
{
    // Set new facing direction if needed.
    if (location.x > _sprite.position.x) {
        [self setDirectionFacing:@"right"];
    } else {
        [self setDirectionFacing:@"left"];
    }

    // Calculate distance and therefore the duration to perform move.
    CGFloat dx = fabs(location.x - _sprite.position.x);
    CGFloat dy = fabs(location.y - _sprite.position.y);
    CGFloat distance = sqrt(dx * dx + dy * dy);

    // NSLog(@"distance: %f", distance);
    
    // Assuming our hero moves 200px per second.
    CGFloat moveDuration = distance / 200;
    
    // Update the texture.
    _sprite.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-still.gif", _facing]];
    
    NSMutableArray *walkFrames = [NSMutableArray array];
    SKTextureAtlas *walkAnimatedAtlas = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"walk-%@", _facing]];
    
    NSUInteger numImages = walkAnimatedAtlas.textureNames.count;
    for (int i=1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [walkAnimatedAtlas textureNamed:textureName];
        [walkFrames addObject:temp];
    }
    
    // Animate our sprite and its feet.
    [_sprite runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:walkFrames
                                       timePerFrame:0.1f
                                             resize:NO
                                            restore:YES]] withKey:@"Move_Hero_Animate"];
    
    // Move our hero. Note that runAction:withKey: will also automatically stop an already running action with the same key.
    SKAction *walkAction = [SKAction moveTo:location duration:moveDuration];

    SKAction *completion = [SKAction runBlock:^{
        // Stop walking animation.
        [_sprite removeActionForKey: @"Move_Hero_Animate"];
    }];
    
    SKAction *sequence = [SKAction sequence:@[ walkAction, completion ]];
    
    [_sprite runAction:sequence withKey:@"Move_Hero"];
    [_spriteFeet runAction:sequence withKey:@"Move_Hero_Feet"];
}

@end