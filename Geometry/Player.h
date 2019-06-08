//
//  Player.h
//  Geometry
//
//  Created by Ярослав Ерохин on 24.10.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JCJoystick.h"
#import "Enemy.h"
#import "CGVectorAdditions.h"

@interface Player : SKSpriteNode
-(instancetype)initWithPosition:(CGPoint)pos;
-(void)moveWithDirection:(CGPoint)direction deltaTime:(float)_dt andBorderNode:(CGRect)borderFrame;
-(void)dieWithEnemy:(Enemy*)enemy andCompletionHandler:(void (^)(void))complete;
-(void)killAllEnemies;
@end
