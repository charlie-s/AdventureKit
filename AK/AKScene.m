
#import "AKScene.h"
#import "AKSprite.h"
#import "JSTileMap.h"
#import "HUMAStarPathfinder.h"

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
        
        // Set hero sprite.
        self.hero = [AKSprite initIntoScene:self];
        [self.hero setDirectionFacing:@"left"];
        [self.hero moveTo:CGPointMake(600, 200)];
        [self addChild:self.hero];
    }
    
    return self;
}

/**
 * Load the given scene number.
 */
-(void)loadSceneNumber:(int)number
{
    NSLog(@"Loading scene #%i.", number);
    
    // Load scene plist.
    NSString * path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", number] ofType:@"plist"];
    _plist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // Load the tilemap.
    self.tileMap = [JSTileMap mapNamed:[NSString stringWithFormat:@"%i.tmx", number]];
    if (self.tileMap) [self addChild:self.tileMap];
    
    // Initialize HUMAStarPathfinder.
    self.pathfinder = [HUMAStarPathfinder pathfinderWithTileMapSize:self.tileMap.mapSize tileSize:self.tileMap.tileSize delegate:self];
}

/**
 * Implements pathfinder:canWalkToNodeAtTileLocation:
 */
- (BOOL)pathfinder:(HUMAStarPathfinder *)pathFinder canWalkToNodeAtTileLocation:(CGPoint)tileLocation
{
    TMXLayer *meta = [self.tileMap layerNamed:@"wall"];
    SKSpriteNode *tile = [meta tileAtCoord:tileLocation];
    
    return (tile == NULL);
    
    // @todo would like to know how the GID stuff below works – what is GID?
    
    //	CCTMXLayer *meta = [self.tileMap layerNamed:@"Meta"];
    //	uint8_t gid = [meta tileGIDAt:tileLocation];
    //
    //	BOOL walkable = YES;
    //
    //	if (gid) {
    //		NSDictionary *properties = [self.tileMap propertiesForGID:gid];
    //		walkable = [properties[@"walkable"] boolValue];
    //	}
    //
    //	return walkable;
    return true;
}

/**
 * Implements pathfinder:costForNodeAtTileLocation:
 */
- (NSUInteger)pathfinder:(HUMAStarPathfinder *)pathfinder costForNodeAtTileLocation:(CGPoint)tileLocation
{
    //	CCTMXLayer *ground = [self.tileMap layerNamed:@"Ground"];
    //	uint32_t gid = [ground tileGIDAt:tileLocation];
    //
    //	NSUInteger cost = pathfinder.baseMovementCost;
    //
    //	if (gid) {
    //		NSDictionary *properties = [self.tileMap propertiesForGID:gid];
    //		if (properties[@"cost"]) {
    //			cost = [properties[@"cost"] integerValue];
    //		}
    //	}
    //    
    //	return cost;
    return 10;
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
    dialogText.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    dialogText.text = text;
    dialogText.fontSize = 30;
    dialogText.fontColor = [SKColor blackColor];
    dialogText.position = CGPointMake(10.0, 450.0);

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
    
    /**
     * Walk
     */
    if (_activeCursor == 1) {;
        // Calculate the fastest path using HUMAStarPathfinder.
        NSArray *walkPath = [self.pathfinder findPathFromStart:self.hero.getPosition toTarget:location];
        
        // Walk the hero.
        [self.hero walkTo:walkPath];
    }
    
    /**
     * Look
     */
    if (_activeCursor == 2) {
        [self showDialog:[[_plist valueForKey:@"action"] valueForKey:@"look"]];
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
