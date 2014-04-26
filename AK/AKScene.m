
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
    NSString *_currentMusic;
    int _activeCursor;
    NSString *_activeCursorImage;
    bool _clickCanResume;
    AKSprite *_hero;
    SKSpriteNode *_portal;
    NSDictionary *_plist;
}

/**
 * Override initWithSize
 */
-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // Load hero sprite.
        _hero = [[AKSprite alloc] initIntoScene:self];
        // Set hero position.
        [_hero setDirectionFacing:@"left"];
        [_hero moveTo:CGPointMake(480, 200)];
        [self addChild:_hero];
        
        // Load the current screen.
        _currentScreen = 1;
        [self loadScreenNumber:_currentScreen];
    }
    
    return self;
}

/**
 * Update the scene music.
 */
-(void)updateMusic:(NSString*)musicName
{
    // If music doesn't change, do nothing.
    if ([_currentMusic isEqualToString:musicName]) {
        return;
    }
    
    // If music does change, fade out the old
    // @todo
    
    // Start new music.
    _currentMusic = musicName;
    NSString *musicFile = [NSString stringWithFormat:@"%@.mp3", _currentMusic];
    [self.scene runAction:[SKAction playSoundFileNamed:musicFile waitForCompletion:NO]];
}

/**
 * Load the given scene number.
 */
-(void)loadScreenNumber:(int)number
{
    NSLog(@"Loading scene #%i.", number);
    _currentScreen = number;
    
    // Load scene plist.
    NSString * path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", number] ofType:@"plist"];
    _plist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // Load music.
    [self updateMusic:[_plist valueForKey:@"music"]];
    
    // Add animations.
    // @todo add via plist
    SKTextureAtlas *animAtlas = [SKTextureAtlas atlasNamed:@"1_anim_left_candle"];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[animAtlas textureNamed:@"1"]];
    [animFrames addObject:[animAtlas textureNamed:@"2"]];
    [animFrames addObject:[animAtlas textureNamed:@"3"]];
    [animFrames addObject:[animAtlas textureNamed:@"4"]];
    [animFrames addObject:[animAtlas textureNamed:@"3"]];
    [animFrames addObject:[animAtlas textureNamed:@"2"]];
    SKAction *animateLeftCandle = [SKAction animateWithTextures:animFrames timePerFrame:0.1f resize:NO restore:YES];
    SKSpriteNode *leftCandle = [SKSpriteNode spriteNodeWithTexture:[animAtlas textureNamed:@"1"]];
    leftCandle.position = CGPointMake(227, 337);
    leftCandle.zPosition = -1;
    [self addChild:leftCandle];
    [leftCandle runAction:[SKAction repeatActionForever:animateLeftCandle] withKey:@"Animate_Candle"];
    
    // Remove the old tilemap
    // @todo there has to be an easier way to remove / replace old objects?
    SKNode *oldTileMap = [self.scene childNodeWithName:@"tilemap"];
    if (oldTileMap) {
        [oldTileMap removeFromParent];
    }
    
    // Load the tilemap.
    self.tileMap = [JSTileMap mapNamed:[NSString stringWithFormat:@"%i.tmx", number]];
    self.tileMap.name = @"tilemap";
    [self addChild:self.tileMap];
    
    // Initialize HUMAStarPathfinder.
    self.pathfinder = [HUMAStarPathfinder pathfinderWithTileMapSize:self.tileMap.mapSize tileSize:self.tileMap.tileSize delegate:self];
    
    // Load portals.
    // @todo add to array of portals
    for (id object in [_plist valueForKey:@"portal"]) {
        NSPoint portalPoint = NSPointFromString([object valueForKey:@"point"]);
        NSSize portalSize = NSSizeFromString([object valueForKey:@"size"]);
        
        _portal = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:portalSize];
        _portal.position = portalPoint;
        _portal.name = @"portal";
        
        _portal.userData = [NSMutableDictionary dictionary];
        [_portal.userData setValue:[object valueForKey:@"screen"] forKey:@"screen"];
        [_portal.userData setValue:[object valueForKey:@"destination"] forKey:@"destination"];
        
        [self addChild:_portal];
    }
}

-(JSTileMap*)getTileMap
{
    return self.tileMap;
}

/**
 * Implements pathfinder:canWalkToNodeAtTileLocation:
 */
- (BOOL)pathfinder:(HUMAStarPathfinder *)pathFinder canWalkToNodeAtTileLocation:(CGPoint)tileLocation
{
    // Check if this is a block layer.
    TMXLayer *meta = [self.tileMap layerNamed:@"block"];
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
        NSArray *walkPath = [self.pathfinder findPathFromStart:_hero.getPosition toTarget:location];
        
        // Walk the hero.
        [_hero walkTo:walkPath];
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
    
    // Check for portal hit.
    NSArray *nodesAtPoint = [self nodesAtPoint:[_hero getPosition]];
    for (SKNode *node in nodesAtPoint) {
        if ([node.name isEqualToString:@"portal"]) {
            [_hero moveTo:NSPointFromString([_portal.userData objectForKey:@"destination"])];
            NSString *screenNumber = [_portal.userData objectForKey:@"screen"];
            [self loadScreenNumber:[screenNumber intValue]];
        }
    }
}

@end
