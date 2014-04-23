
#import "AKScene.h"

static const uint32_t playerCategory = 0x1 << 0;
static const uint32_t blockCategory = 0x1 << 1;
static const uint32_t playerFeetCategory = 0x1 << 2;
static const uint32_t blockFeetCategory = 0x1 << 3;

/**
 * Category of SKView to invoke rightMouseDown event. This is normally not 
 * passed up the chain to the SKScene/AKScene so we must let it be called
 * here and then invoke our scene's rightMouseDown method.
 */
@implementation SKView (Right_Mouse)
-(void)rightMouseDown:(NSEvent *)theEvent
{
    [self.scene rightMouseDown:theEvent];
}
@end

@implementation AKScene
{
    int _currentScreen;
    int _activeCursor;
    NSString *_activeCursorImage;
    bool _clickCanResume;

    NSDictionary *_plist;
    
    SKShapeNode *_boundary1;
}

/**
 * Override initWithSize
 */
-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // Load the current screen.
        _currentScreen = 1;
        [self loadSceneNumber:_currentScreen];
        
        /**
         * Set hero sprite.
         */
        self.hero = [[AKSprite alloc] init];
        [self.hero setDirectionFacing:@"left"];
        [self.hero moveTo:CGPointMake(600, 200)];
        [self addChild:self.hero];
    }
    
    return self;
}

/**
 * Load the given scene number.
 */
-(id)loadSceneNumber:(int)number
{
    // Load scene plist.
    NSString * path = [[NSBundle mainBundle] pathForResource:@"001" ofType:@"plist"];
    _plist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // Load music
    // [self runAction:[SKAction playSoundFileNamed:@"1.mp3" waitForCompletion:NO]];
    
    // Set background, centered.
    SKSpriteNode *bgImage = [SKSpriteNode spriteNodeWithImageNamed:@"001.png"];
    bgImage.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:bgImage];
    
    // Draw boundaries.
    _boundary1 = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, 155, 0);
    CGPathAddLineToPoint(pathToDraw, NULL, 190, 90);
    CGPathAddLineToPoint(pathToDraw, NULL, 187, 165);
    CGPathAddLineToPoint(pathToDraw, NULL, 175, 175);
    CGPathAddLineToPoint(pathToDraw, NULL, 175, 366);
    CGPathAddLineToPoint(pathToDraw, NULL, 201, 390);
    CGPathAddLineToPoint(pathToDraw, NULL, 200, 176);
    CGPathAddLineToPoint(pathToDraw, NULL, 238, 236);
    CGPathAddLineToPoint(pathToDraw, NULL, 332, 238);
    CGPathAddLineToPoint(pathToDraw, NULL, 359, 251);
    CGPathAddLineToPoint(pathToDraw, NULL, 600, 251);
    _boundary1.path = pathToDraw;
    [_boundary1 setStrokeColor:[SKColor blueColor]];
    [self addChild:_boundary1];

    return self;
}

/**
 * Pause the scene.
 */
-(void)pause
{
    NSLog(@"Paused.");
    _activeCursorImage = @"wait";
    [self updateCursor];
    self.scene.view.paused = YES;
}

/**
 * Resume the scene.
 */
-(void)resume
{
    NSLog(@"Resumed.");
    self.scene.view.paused = NO;
    _clickCanResume = false;
}

/**
 * Show a text dialog.
 */
-(void)showDialog:(NSString*)text
{
    // Build shape.
    SKShapeNode *dialogBackground = [[SKShapeNode alloc] init];
    CGRect brickBoundary = CGRectMake(0.0, 0.0, 960.0, 100.0);
    dialogBackground.name = @"dialogBackground";
    dialogBackground.position = CGPointMake(0.0, 440.0);
    dialogBackground.path = CGPathCreateWithRect(brickBoundary, nil);
    dialogBackground.fillColor = [SKColor brownColor];

    [self addChild:dialogBackground];
    
    // Add text.
    SKLabelNode *dialogText = [SKLabelNode labelNodeWithFontNamed:@"Times"];
    dialogText.name = @"dialogText";
    dialogText.text = text;
    dialogText.fontSize = 11;
    dialogText.fontColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    dialogText.position = CGPointMake(150.0, 250.0);

    [self addChild:dialogText];
    
    // Set dialog flag that can be cleared with leftclick.
    _clickCanResume = true;
    
    // Pause.
    [self pause];
}

/**
 * Clear the current text dialog.
 */
-(void)clearDialog
{
    SKNode *dialogBackground = [self childNodeWithName:@"dialogBackground"];
    [dialogBackground removeFromParent];
    
    SKNode *dialogText = [self childNodeWithName:@"dialogText"];
    [dialogText removeFromParent];
}

/**
 *
 */
-(void)didEvaluateActions
{
}

/**
 * Update the cursor image.
 */
-(void)updateCursor
{
    // Set cursor image depending upon currnt _activeCursorImage.
    NSString *file = [[NSBundle mainBundle] pathForResource:_activeCursorImage ofType:@"png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
    NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint(0, 0)];
    [cursor set];
}

/**
 * Left click.
 */
-(void)mouseDown:(NSEvent *)theEvent
{
    // If the scene is currently paused and _clickCanResume, clear any dialog's and
    // resume the scene.
    if (self.scene.view.paused & _clickCanResume) {
        [self clearDialog];
        [self resume];
        return;
    }
    
    // Get the point clicked.
    CGPoint location = [theEvent locationInNode:self];
    
    // Set proper action depending on current active cursor.
    switch (_activeCursor) {
        case 1:
            [self.hero walkTo:location];
            break;
            
        case 2:
            [self showDialog:[[_plist valueForKey:@"action"] valueForKey:@"look"]];
            break;
            
        default:
            NSLog(@"No activeCursor set.");
            break;
    }
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
    // Increase the activeCursor, resetting when we hit the top-most item.
    _activeCursor++;
    
    if (_activeCursor > 2) {
        _activeCursor = 1;
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    if (CGRectIntersectsRect(skView.frame, node.frame) {

        NSLog(@"Intersection");
    }
        
    if ([self.hero intersectsNode:_boundary1]) {

    }
    
    // Determine current cursor image depending upon current _activeCursor.
    switch (_activeCursor) {
        case 1:
            _activeCursorImage = @"walk";
            break;
            
        case 2:
            _activeCursorImage = @"look";
            break;
            
        default:
            _activeCursorImage = @"default";
            break;
    }
    
    [self updateCursor];
}

@end
