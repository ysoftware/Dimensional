//
//  Enemy.h
//  Geometry
//
//  Created by Ярослав Ерохин on 24.10.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "CGVectorAdditions.h"
#import "AppDelegate.h"
#import "Multiplier.h"

#define PLAYER_SPEED 400
#define PROJECTILE_SPEED 900

#define ENEMY_RECTANGLE_SPEED 100
#define ENEMY_ETRIANGLE_SPEED 150
#define ENEMY_RHOMB_SPEED 250
#define ENEMY_PENTAGON_SPEED 200
#define ENEMY_ITRIANGLE_SPEED 350

#define ENEMY_TYPE_RECTANGLE @"rectangleEnemy"
#define ENEMY_TYPE_ETRIANGLE @"equilateralTriangleEnemy"
#define ENEMY_TYPE_ITRIANGLE @"isoscelesTriangleEnemy"
#define ENEMY_TYPE_PENTAGON @"pentagonEnemy"
#define ENEMY_TYPE_SPENTAGON @"smallPentagonEnemy"
#define ENEMY_TYPE_RHOMB @"rhombEnemy"

#define ENEMY_COLOR_RECTANGLE 0x408cff
#define ENEMY_COLOR_ETRIANGLE 0x4bda64
#define ENEMY_COLOR_ITRIANGLE 0xffcc00
#define ENEMY_COLOR_PENTAGON 0xff5f57
#define ENEMY_COLOR_SPENTAGON 0xff4060
#define ENEMY_COLOR_RHOMB 0x59cdff

@interface Enemy : SKSpriteNode

typedef enum : int32_t {
    EmptyCategoryBitMask = 0,
    PlayerCategoryBitMask = 1,
    EnemyCategoryBitMask = 2,
    ProjectileCategoryBitMask = 4,
    MultiplierCategoryBitMask = 8,
    WallCategoryBitMask = 16,
    PlayerFieldCategoryBitMask = 32,
    BackgroundCirclesFieldCategoryBitMask = 64
} CategoryBitMask;

@property (strong, nonatomic) NSString *type;
@property (assign, nonatomic, readonly) BOOL isPositionAbsolute;
@property (assign, nonatomic, readonly) BOOL isFacingPlayer;
@property (assign, nonatomic, getter=isMoving) BOOL moving;
@property (assign, nonatomic) float spawnTime;
@property (assign, nonatomic, getter=isContactVisible) BOOL contactVisible;
@property (assign, nonatomic, getter=isprojectileContactVisible) BOOL projectileContactVisible;

-(void)correctPosition:(CGRect)borderFrame;
-(void)animateIn;
-(void)didHitWall;
-(void)moveWithDeltaTime:(float)_dt borderNode:(CGRect)borderFrame playerPosition:(CGPoint)playerPos andProjectiles:(NSArray*)projectiles;
-(Multiplier*)didHitProjectile;
-(void)refreshPhysicsBodyAndSetPosition:(CGPoint)position;
-(instancetype)initWithType:(NSString*)type
                   position:(CGPoint)pos
         isPositionAbsolute:(BOOL)isPositionAbsolute
               angleDegrees:(float)angle
           orIsFacingPlayer:(BOOL)isFacingPlayer
     alsoPassPlayerPosition:(CGPoint)playerPosition
                  spawnTime:(float)spawnTime;
@end
