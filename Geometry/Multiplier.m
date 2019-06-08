//
//  Multiplier.m
//  Geometry
//
//  Created by Ярослав Ерохин on 07.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "Multiplier.h"
#import "Enemy.h"

@implementation Multiplier
-(instancetype)initWithPosition:(CGPoint)position{
    self = [super init];
    if (self){
        _contactVisible = YES;
        self.colorBlendFactor = 1;
        self.size = CGSizeMake(10, 10);
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Gameplay"];
        self.texture = [atlas textureNamed:@"multiplier"];
        self.position = position;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
        self.physicsBody.charge = 1;
        self.physicsBody.collisionBitMask = EmptyCategoryBitMask;
        self.physicsBody.contactTestBitMask = PlayerCategoryBitMask;
        self.physicsBody.categoryBitMask = MultiplierCategoryBitMask;
        self.physicsBody.fieldBitMask = PlayerFieldCategoryBitMask;
        self.physicsBody.usesPreciseCollisionDetection = YES;
    }
    return self;
}

-(void)dieIn:(float)seconds{
    SKAction *fadeOut = [SKAction fadeOutWithDuration:.1];
    SKAction *fadeIn = [SKAction fadeInWithDuration:.1];
    SKAction *blink = [SKAction sequence:@[fadeOut, fadeIn, fadeOut, fadeIn, fadeOut, fadeIn]];
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:seconds-blink.duration], blink, [SKAction runBlock:^{
        [self die];
    }]]]];
}

-(void)die{
    _contactVisible = NO;
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
