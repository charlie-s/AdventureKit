
#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

@interface AKSprite : SKNode

-(void)moveTo:(CGPoint)point;
-(void)walkTo:(NSArray*)walkPath;
-(void)setDirectionFacing:(NSString*)direction;

-(CGSize)getSize;
-(CGPoint)getPosition;

@end
