
#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

@interface AKSprite : SKNode

-(void)moveTo:(CGPoint)point;
-(void)walkTo:(CGPoint)point;
-(void)setDirectionFacing:(NSString*)direction;
-(CGSize)getSize;

@end
