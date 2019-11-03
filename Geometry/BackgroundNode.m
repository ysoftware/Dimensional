//
//  BackgroundNode.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 23.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//
#import "AppDelegate.h"
#include <stdlib.h>
#import "BackgroundNode.h"
#import "Enemy.h"
#import "MainView.h"

@implementation BackgroundNode{
    SKNode *rootBackgroundNode;
    NSMutableArray *bigCircles, *mediumCircles, *smallCircles;
    CGRect topLeft, topRight, bottomLeft, bottomRight;
    NSString *chapterId;
}

#pragma mark - Node life cycle

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size andCirclesNode:(SKNode*)node{
    self = [super initWithColor:color size:size];
    if (self) {
        rootBackgroundNode = node;
        [self addChild:node];//adding background circles
        self.zPosition = -2;
        self.colorBlendFactor = 1;
        self.color = BACKGROUND_COLOR_1;
        [self scaleTo:.7 withDuration:0];

        bigCircles = [[NSMutableArray alloc] init];
        mediumCircles = [[NSMutableArray alloc] init];
        smallCircles = [[NSMutableArray alloc] init];

        float x = 1536; float y = 1152;

        SKRange *rangeX = [SKRange rangeWithLowerLimit:-x/2 upperLimit:x/2];
        SKRange *rangeY = [SKRange rangeWithLowerLimit:-y/2 upperLimit:y/2];
        SKConstraint *constraint = [SKConstraint positionX:rangeX Y:rangeY];

        for (SKNode *node in rootBackgroundNode.children) {
            if ([node.name isEqualToString:@"BigCircle"]){
                SKSpriteNode *circle = (SKSpriteNode*)node;
                [self->bigCircles addObject:circle];
                circle.physicsBody.fieldBitMask = BackgroundCirclesFieldCategoryBitMask;
                circle.physicsBody.categoryBitMask = EmptyCategoryBitMask;
                circle.physicsBody.collisionBitMask = EmptyCategoryBitMask;
                circle.physicsBody.contactTestBitMask = EmptyCategoryBitMask;
                circle.physicsBody.mass = 3;
                circle.constraints = @[constraint];
                if (arc4random()%5%3==0){ circle.colorBlendFactor = .3; } else { circle.colorBlendFactor = 0; }
            }
            else if([node.name isEqualToString:@"MediumCircle"]){
                SKSpriteNode *circle = (SKSpriteNode*)node;
                [self->mediumCircles addObject:circle];
                circle.physicsBody.fieldBitMask = BackgroundCirclesFieldCategoryBitMask;
                circle.physicsBody.categoryBitMask = EmptyCategoryBitMask;
                circle.physicsBody.collisionBitMask = EmptyCategoryBitMask;
                circle.physicsBody.contactTestBitMask = EmptyCategoryBitMask;
                circle.physicsBody.mass = 2;
                circle.constraints = @[constraint];
                if (arc4random()%5%3==0){ circle.colorBlendFactor = .3; } else { circle.colorBlendFactor = 0; }
            }
            else if ([node.name isEqualToString:@"SmallCircle"]){
                SKSpriteNode *circle = (SKSpriteNode*)node;
                [self->smallCircles addObject:circle];
                circle.physicsBody.fieldBitMask = BackgroundCirclesFieldCategoryBitMask;
                circle.physicsBody.categoryBitMask = EmptyCategoryBitMask;
                circle.physicsBody.collisionBitMask = EmptyCategoryBitMask;
                circle.physicsBody.contactTestBitMask = EmptyCategoryBitMask;
                circle.physicsBody.mass = 1;
                circle.constraints = @[constraint];
                if (arc4random()%5%3 ==0){ circle.colorBlendFactor = .3; } else { circle.colorBlendFactor = 0; }
            }
            else if ([node.name isEqualToString:@"CirclesField"]){
                SKFieldNode *field = (SKFieldNode*)node;
                field.categoryBitMask = BackgroundCirclesFieldCategoryBitMask;
                field.strength = .001;
            }
        }
    }
    return self;
}

#pragma mark - Utilities

- (NSInteger)getRandomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max{
    return min + arc4random() % (max - min + 1);
}

-(SKColor*)inverseColor:(SKColor*)color{
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    SKColor *newColor = [[SKColor alloc] initWithRed:(1.0 - componentColors[0]) green:(1.0 - componentColors[1]) blue:(1.0 - componentColors[2]) alpha:componentColors[3]];
    return newColor;
}

#pragma mark - Animations

-(void)scaleTo:(float)scale withDuration:(float)duration{
    SKAction *scaleAnimation = [SKAction scaleTo:scale duration:duration];
    [rootBackgroundNode runAction:scaleAnimation];
}

-(void)moveTo:(CGPoint)position withDuration:(float)duration{
    SKAction *moveAnimation = [SKAction moveTo:position duration:duration];
    [rootBackgroundNode runAction:moveAnimation];
}

-(SKColor*)colorForLevel:(NSInteger)level{
    switch (level) {
        case 0: return BACKGROUND_COLOR_0; break;
        case 1: return BACKGROUND_COLOR_1; break;
        case 2: return BACKGROUND_COLOR_2; break;
        case 3: return BACKGROUND_COLOR_3; break;
        case 4: return BACKGROUND_COLOR_4; break;
        case 5: return BACKGROUND_COLOR_5; break;
        case 6: return BACKGROUND_COLOR_6; break;
        case 7: return BACKGROUND_COLOR_7; break;
        case 8: return BACKGROUND_COLOR_8; break;
        case 9: return BACKGROUND_COLOR_9; break;
        case 10: return BACKGROUND_COLOR_10; break;
        default: return BACKGROUND_COLOR_0; break;
    }
}

-(void)switchColorsForLevel:(NSInteger)level{
    SKAction *animation = [SKAction colorizeWithColor:[self colorForLevel:level] colorBlendFactor:1 duration:1.5];
    [self runAction:animation];

    for (SKSpriteNode *s in bigCircles){
        s.color = [self inverseColor:[self colorForLevel:level]];}
    for (SKSpriteNode *s in mediumCircles){
        s.color = [self inverseColor:[self colorForLevel:level]];}
    for (SKSpriteNode *s in smallCircles){
        s.color = [self inverseColor:[self colorForLevel:level]];}
}
@end
