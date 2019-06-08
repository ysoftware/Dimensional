//
//  Player.m
//  Geometry
//
//  Created by Ярослав Ерохин on 24.10.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "Player.h"
#import "Enemy.h"
#import "Projectile.h"

@interface Player ()
@property (strong, nonatomic) SKFieldNode *fieldNode;
@end

@implementation Player
@synthesize fieldNode;

-(instancetype)initWithPosition:(CGPoint)pos{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"player"] color:[SKColor whiteColor] size:CGSizeMake(35, 35)];
    if (self){
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.position = pos;

        //physics body
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        self.physicsBody.categoryBitMask = PlayerCategoryBitMask;
        self.physicsBody.contactTestBitMask = EmptyCategoryBitMask;
        self.physicsBody.collisionBitMask = WallCategoryBitMask;
        self.physicsBody.fieldBitMask = EmptyCategoryBitMask;
        self.physicsBody.usesPreciseCollisionDetection = YES;

        fieldNode = [SKFieldNode radialGravityField];
        fieldNode.categoryBitMask = PlayerFieldCategoryBitMask;
        fieldNode.position = self.position;
        fieldNode.strength = 10;
        fieldNode.region = [[SKRegion alloc] initWithRadius:200];

        [self addChild:fieldNode];
        SKFieldNode *dragNode = [SKFieldNode dragField];
        [self addChild:dragNode];
    }
    return self;
}

-(void)moveWithDirection:(CGPoint)direction deltaTime:(float)_dt andBorderNode:(CGRect)borderFrame{
    CGPoint velocity = CGPointMake(direction.x*PLAYER_SPEED*_dt, direction.y*PLAYER_SPEED*_dt);
    CGPoint newPosition = addPoints(velocity, self.position);

    self.position = newPosition;
    if (!CGRectContainsPoint(borderFrame, CGPointMake(borderFrame.origin.x, self.position.y))){
        if (borderFrame.origin.y < self.position.y){
            float newY = borderFrame.origin.y + borderFrame.size.height - self.size.height/2 - 5;
            self.position = CGPointMake(self.position.x, newY);
        }
        else{
            float newY = borderFrame.origin.y + self.size.height/2  + 5;
            self.position = CGPointMake(self.position.x, newY);
        }
    }
    //X
    if(!CGRectContainsPoint(borderFrame, CGPointMake(self.position.x, borderFrame.origin.y))){
        if (borderFrame.origin.x < self.position.x){
            float newX = borderFrame.origin.x + borderFrame.size.width - self.size.width/2 - 5;
            self.position = CGPointMake(newX, self.position.y);
        }
        else{
            float newX = borderFrame.origin.x + self.size.width/2 + 5;
            self.position = CGPointMake(newX, self.position.y);
        }
    }

    [self runAction:[SKAction rotateToAngle:CGVectorAngle(CGVectorMake(velocity.x, velocity.y)) duration:.1 shortestUnitArc:YES]];
}

-(void)dieWithEnemy:(Enemy*)enemy andCompletionHandler:(void (^)(void)) complete{
    SKAction *killPlayer = [SKAction group:@[[SKAction fadeOutWithDuration:.3], [SKAction scaleTo:.5 duration:.3]]];
    SKAction *killEnemy = [SKAction sequence:@[[SKAction group:@[[SKAction fadeOutWithDuration:.4], [SKAction scaleTo:2 duration:.4]]], [SKAction runBlock:^{[enemy removeFromParent];}]]];
    [self runAction:killPlayer completion:^{
        complete();
    }];
    if (enemy != nil){
        [enemy runAction:killEnemy];
    }
}

-(void)killAllEnemies{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"player_wave"] size:CGSizeMake(35, 35)];
    node.colorBlendFactor = 1;
    node.color = [SKColor whiteColor];
    [self addChild:node];

    SKAction *expand = [SKAction scaleTo:50 duration:.35];
    [node runAction:[SKAction sequence:@[expand, [SKAction runBlock:^{
        [node removeFromParent];
    }]]]];
}

@end
