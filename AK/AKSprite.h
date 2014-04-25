
#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

@class AKScene;

@interface AKSprite : SKNode

-(id)initIntoScene:(AKScene*)scene;
-(void)moveTo:(CGPoint)point;
-(void)walkTo:(NSArray*)walkPath;
-(void)setDirectionFacing:(NSString*)direction;

-(CGSize)getSize;
-(CGPoint)getPosition;

@end
