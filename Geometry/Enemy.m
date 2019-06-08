//
//  Enemy.m
//  Geometry
//
//  Created by Ярослав Ерохин on 24.10.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "Enemy.h"
#import "Projectile.h"

@interface Enemy ()
@property (readonly, nonatomic, assign) float movement_speed;
@end

@implementation Enemy
@synthesize movement_speed;

-(instancetype)initWithType:(NSString*)type
                   position:(CGPoint)pos
         isPositionAbsolute:(BOOL)isPositionAbsolute
               angleDegrees:(float)angle
           orIsFacingPlayer:(BOOL)isFacingPlayer
     alsoPassPlayerPosition:(CGPoint)playerPosition
                  spawnTime:(float)spawnTime{
    self = [super init];
    if (self){
        _contactVisible = NO;
        _projectileContactVisible = YES;
        self.spawnTime = spawnTime;
        self.colorBlendFactor = 1;
        self.type = type;
        self.size = CGSizeMake(40, 40);
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Gameplay"];
        SKTexture *texture = [atlas textureNamed:type];
        self.texture = texture;
        self.anchorPoint = CGPointMake(.5, .5);

        //physics
        _isFacingPlayer = isFacingPlayer;
        _isPositionAbsolute = isPositionAbsolute;
        self.position = pos;

        if (isFacingPlayer){
            self.zRotation = atan2f(playerPosition.y - self.position.y, playerPosition.x - self.position.x);
        }
        else{
            self.zRotation = DEGREES_TO_RADIANS(angle);
        }

        if ([type isEqualToString:ENEMY_TYPE_RECTANGLE]){
            self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
            self.physicsBody.collisionBitMask = 0;
            self.physicsBody.usesPreciseCollisionDetection = YES;
            self.color = SKColorFromHexValue(ENEMY_COLOR_RECTANGLE);
            movement_speed = ENEMY_RECTANGLE_SPEED;
        }
        else if ([type isEqualToString:ENEMY_TYPE_ETRIANGLE]){
            CGPoint points[3];
            points[0] = CGPointMake(-20, -20);
            points[1] = CGPointMake(20, 0);
            points[2] = CGPointMake(-20, 20);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddLines(path, NULL, points, 3);
            self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
            CGPathCloseSubpath(path);
            CGPathRelease(path);

            self.color = SKColorFromHexValue(ENEMY_COLOR_ETRIANGLE);
            movement_speed = ENEMY_ETRIANGLE_SPEED;
        }
        else if ([type isEqualToString:ENEMY_TYPE_ITRIANGLE]){
            CGPoint points[3];
            points[0] = CGPointMake(-20, -17);
            points[1] = CGPointMake(20, 0);
            points[2] = CGPointMake(-20, 17);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddLines(path, NULL, points, 3);
            self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
            CGPathCloseSubpath(path);
            CGPathRelease(path);

            self.physicsBody.collisionBitMask = 0;
            self.color = SKColorFromHexValue(ENEMY_COLOR_ITRIANGLE);
            movement_speed = ENEMY_ITRIANGLE_SPEED;
        }
        else if ([type isEqualToString:ENEMY_TYPE_PENTAGON]){
            CGPoint points[5];
            points[0] = CGPointMake(-0, -12);
            points[1] = CGPointMake(5, -20);
            points[2] = CGPointMake(20, 1);
            points[3] = CGPointMake(4, 20);
            points[4] = CGPointMake(-20, 12);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddLines(path, NULL, points, 5);
            self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
            CGPathCloseSubpath(path);
            CGPathRelease(path);

            self.color = SKColorFromHexValue(ENEMY_COLOR_PENTAGON);
            movement_speed = ENEMY_PENTAGON_SPEED;
        }
        else if ([type isEqualToString:ENEMY_TYPE_SPENTAGON]){
            CGPoint points[5];
            points[0] = CGPointMake(-15, 9);
            points[1] = CGPointMake(-15, -9);
            points[2] = CGPointMake(4, -15);
            points[3] = CGPointMake(15, 0);
            points[4] = CGPointMake(4, 15);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddLines(path, NULL, points, 5);
            self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
            CGPathCloseSubpath(path);
            CGPathRelease(path);

            self.color = SKColorFromHexValue(ENEMY_COLOR_SPENTAGON);
            self.size = CGSizeMake(30, 30);
            movement_speed = ENEMY_PENTAGON_SPEED;
        }
        else if ([type isEqualToString:ENEMY_TYPE_RHOMB]){
            CGPoint points[4];
            points[0] = CGPointMake(-20, 0);
            points[1] = CGPointMake(-1, -17);
            points[2] = CGPointMake(20, 0);
            points[3] = CGPointMake(0, 17);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddLines(path, NULL, points, 4);
            self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
            CGPathCloseSubpath(path);
            CGPathRelease(path);

            self.color = SKColorFromHexValue(ENEMY_COLOR_RHOMB);
            movement_speed = ENEMY_RHOMB_SPEED;
        }

        self.physicsBody.categoryBitMask = EnemyCategoryBitMask;
        self.physicsBody.collisionBitMask = [self.type isEqualToString:ENEMY_TYPE_SPENTAGON] ? (WallCategoryBitMask | EnemyCategoryBitMask) : EmptyCategoryBitMask;
        self.physicsBody.contactTestBitMask = PlayerCategoryBitMask | WallCategoryBitMask;
        self.physicsBody.fieldBitMask = EmptyCategoryBitMask;
    }
    return self;
}

-(void)setContactVisible:(BOOL)contactVisible{
    if (contactVisible){
        [self runAction:[SKAction fadeAlphaTo:1 duration:.15]];
    }
    else{
        [self runAction:[SKAction fadeAlphaTo:.65 duration:0]];
    }

    _contactVisible = contactVisible;
}

-(void)moveWithDeltaTime:(float)_dt borderNode:(CGRect)borderFrame playerPosition:(CGPoint)playerPos andProjectiles:(NSArray*)projectiles{
    if (self.isMoving && self.parent){
        //movement and rotation
        float angle = self.zRotation;
        CGPoint newPosition;

        if ([self.type isEqualToString:ENEMY_TYPE_RECTANGLE] || [self.type isEqualToString:ENEMY_TYPE_ITRIANGLE] || [self.type isEqualToString:ENEMY_TYPE_RHOMB] ){
            CGPoint angleMultiplier = pointAroundCircumferenceFromCenter(CGPointZero, 1, angle);
            CGPoint velocity = CGPointMake(angleMultiplier.x*movement_speed*_dt, angleMultiplier.y*movement_speed*_dt);
            newPosition = addPoints(velocity, self.position);
        }
        else if ([self.type isEqualToString:ENEMY_TYPE_ETRIANGLE] || [self.type isEqualToString:ENEMY_TYPE_PENTAGON]|| [self.type isEqualToString:ENEMY_TYPE_SPENTAGON]){
            angle = atan2f(playerPos.y - self.position.y, playerPos.x - self.position.x);
            CGPoint angleMultiplier = pointAroundCircumferenceFromCenter(CGPointZero, 1, angle);
            CGPoint velocity = CGPointMake(angleMultiplier.x*movement_speed*_dt, angleMultiplier.y*movement_speed*_dt);
            newPosition = addPoints(velocity, self.position);
        }
		else {
			newPosition = self.position;
		}

        if ([self.type isEqualToString:ENEMY_TYPE_RHOMB]){
            //изменение направления
            angle += DEGREES_TO_RADIANS(90*_dt);
        }

        self.position = newPosition;
        self.zRotation = angle;
        [self correctPosition:borderFrame];
    }
}

-(void)correctPosition:(CGRect)borderFrame{
    //POSITION CORRECTION
    //Y
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
}

-(Multiplier*)didHitProjectile{
    _projectileContactVisible = NO;
    _contactVisible = NO;
    self.physicsBody = nil;
    self.moving = NO;

    //partricles
    SKEmitterNode *emitter = [SKEmitterNode unarchiveFromFile:@"enemyExplode"];
    emitter.targetNode = self.parent;
    emitter.particleColor = self.color;
    emitter.position = self.position;
    emitter.particleTexture = self.texture;
    emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[self.color, [SKColor whiteColor]] times:@[@0, @.7]];
    [self.parent addChild:emitter];

    //animation
    [self removeAllActions];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:.3];
    SKAction *scaleDown = [SKAction scaleTo:0 duration:.3];
    SKAction *animation = [SKAction group:@[fadeOut, scaleDown]];
    animation.timingMode = SKActionTimingEaseOut;
    [self runAction:animation completion:^{
        [self removeFromParent];
        [emitter removeFromParent];
    }];
    return [self spawnMultiplier];
}

-(Multiplier*)spawnMultiplier{
    if ([self.type isEqualToString:ENEMY_TYPE_PENTAGON])
        return nil;

    Multiplier *multiplier = [[Multiplier alloc] initWithPosition:self.position];
    multiplier.color = self.color;
    [self.parent addChild:multiplier];
    [multiplier refreshPhysicsBodyAndSetPosition:self.position];
    [multiplier dieIn:3];
    return multiplier;
}

-(void)animateIn{
    self.colorBlendFactor = 0;
    [self setScale:4];

    SKAction *scaleUp = [SKAction scaleTo:1 duration:.15];
    SKAction *colorUp = [SKAction colorizeWithColorBlendFactor:1 duration:.25];
    SKAction *animation = [SKAction group:@[scaleUp, colorUp]];
    animation.timingMode = SKActionTimingEaseInEaseOut;
    [self runAction:animation];
}

-(void)didHitWall{
    //turn around and fly again
    if (self.isMoving && ([self.type isEqualToString:ENEMY_TYPE_ITRIANGLE] || [self.type isEqualToString:ENEMY_TYPE_RECTANGLE] || [self.type isEqualToString:ENEMY_TYPE_RHOMB])){
        self.moving = NO;
        CGPoint angleMultiplier = pointAroundCircumferenceFromCenter(CGPointZero, 1, self.zRotation+DEGREES_TO_RADIANS(180)) ;
        float time = .1;
        CGPoint velocity = CGPointMake(angleMultiplier.x*movement_speed*time, angleMultiplier.y*movement_speed*time);
        CGPoint newPosition = addPoints(velocity, self.position);
        SKAction *turnAroundAction = [SKAction sequence:@[[SKAction moveTo:newPosition duration:time],
                                                          [SKAction runBlock:^{ self.zRotation += DEGREES_TO_RADIANS(180); self.moving = YES; }]]];
        turnAroundAction.timingMode = SKActionTimingEaseInEaseOut;
        [self runAction:turnAroundAction];
    }
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
