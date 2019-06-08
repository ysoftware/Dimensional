//
//  Projectile.m
//  Geometry
//
//  Created by Ярослав Ерохин on 06.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "Projectile.h"
#import "Enemy.h"

@implementation Projectile

-(instancetype)initWithPosition:(CGPoint)position andAngle:(float)angle{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"projectile"] color:[SKColor whiteColor] size:CGSizeMake(7, 7)];
    if (self){
        self.colorBlendFactor = 1;
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Gameplay"];
        self.texture = [atlas textureNamed:@"projectile"];

        self.position = position;
        self.zRotation = angle;

        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        self.physicsBody.collisionBitMask = WallCategoryBitMask;
        self.physicsBody.contactTestBitMask = EnemyCategoryBitMask | WallCategoryBitMask;
        self.physicsBody.categoryBitMask = ProjectileCategoryBitMask;
        self.physicsBody.fieldBitMask = EmptyCategoryBitMask;
        self.physicsBody.usesPreciseCollisionDetection = YES;
    }
    return self;
}

-(void)moveWithDeltaTime:(float)_dt andBorderNode:(CGRect)borderFrame{
    float angle = self.zRotation;
    CGPoint angleMultiplier = pointAroundCircumferenceFromCenter(CGPointZero, 1, angle);
    CGPoint velocity = CGPointMake(angleMultiplier.x*PROJECTILE_SPEED*_dt, angleMultiplier.y*PROJECTILE_SPEED*_dt);
    CGPoint newPosition = addPoints(self.position, velocity);
    self.position = newPosition;
    if (!CGRectContainsPoint(borderFrame, newPosition)){
        [self die];
    }
}

-(void)die{
    self.physicsBody = nil;
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:.3];
    SKAction *scaleDown = [SKAction scaleTo:0 duration:.3];
    SKAction *animation = [SKAction group:@[fadeOut, scaleDown]];

    [self runAction:animation completion:^{
        [self removeFromParent];
        [self->_containingArray removeObject:self];
    }];
}

-(void)refreshPhysicsBodyAndSetPosition:(CGPoint)position{

    /*
     * Weird thing here: if I just set the position of these nodes, they
     * end up at position (0,0). However, if I remove the physics body, set
     * the position, and then re-add the physics body, the nodes are
     * placed correctly.
     */

    SKPhysicsBody *tempPhysicsBody = self.physicsBody;
    self.physicsBody = nil;

    // Position and re-add physics body
    self.position = position;
    self.physicsBody = tempPhysicsBody;
}
@end
