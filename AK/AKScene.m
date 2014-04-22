
#import "AKScene.h"

static const uint32_t blockCategory = 0x1 << 0;
static const uint32_t playerCategory = 0x1 << 1;

@implementation AKScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;

        // Set default cursor.
        if (self.cursorActiveImage.length == 0) {
            self.cursorActiveImage = @"cursor-default";
        }
        
        // Set background, centered.
        SKSpriteNode *bgImage = [SKSpriteNode spriteNodeWithImageNamed:@"001.png"];
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bgImage];
        
        // Set toolbar.
        //        SKShapeNode *toolbarBg = [[SKShapeNode alloc] init];
        //        CGRect brickBoundary = CGRectMake(0.0, 0.0, 960.0, 100.0);
        //        toolbarBg.position = CGPointMake(0.0, 440.0);
        //        toolbarBg.path = CGPathCreateWithRect(brickBoundary, nil);
        //        toolbarBg.fillColor = [SKColor brownColor];
        //        [self addChild:toolbarBg];
        
        // Load music
        //        [self runAction:[SKAction playSoundFileNamed:@"001.mp3" waitForCompletion:NO]];
        
        /**
         * Set hero sprite.
         */
        self.hero = [[AKSprite alloc] init];
        [self.hero setDirectionFacing:@"left"];
        [self.hero moveTo:CGPointMake(600, 200)];
        [self addChild:self.hero];
        
        /**
         * Set a block.
         */
        SKSpriteNode *block = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(300, 300)];
        block.position = CGPointMake(200, 200);
        [self addChild:block];
        
        block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
        block.physicsBody.dynamic = NO;
        block.physicsBody.categoryBitMask = blockCategory;
        block.physicsBody.collisionBitMask = 0;
        block.physicsBody.contactTestBitMask = playerCategory;

    }
    
    return self;
}

/**
 * Collision detected.
 */
-(void)didBeginContact:(SKPhysicsContact*)contact
{
    NSLog(@"contact detected!");
    
    //    SKPhysicsBody *firstBody;
    //    SKPhysicsBody *secondBody;
    
    //    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    //    {
    //        firstBody = contact.bodyA;
    //        secondBody = contact.bodyB;
    //    }
    //    else
    //    {
    //        firstBody = contact.bodyB;
    //        secondBody = contact.bodyA;
    //    }
    
    //Your first body is the block, secondbody is the player.
    //Implement relevant code here.
    
}

-(void)didEvaluateActions
{
    // Set custom mouse cursor.
    NSString *file = [[NSBundle mainBundle] pathForResource:self.cursorActiveImage ofType:@"png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
    NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint(0, 0)];
    [cursor set];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    // Get the point clicked.
    CGPoint location = [theEvent locationInNode:self];
    
    [self.hero walkTo:location];
}

-(void)update:(CFTimeInterval)currentTime {}

@end
