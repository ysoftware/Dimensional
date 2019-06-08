//
//  Multiplier.h
//  Geometry
//
//  Created by Ярослав Ерохин on 07.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Multiplier : SKSpriteNode
@property (assign, nonatomic, readonly, getter=isContactVisible) BOOL contactVisible;
@property (strong, nonatomic) NSMutableArray *containingArray;

-(instancetype)initWithPosition:(CGPoint)position;
-(void)dieIn:(float)seconds;
-(void)die;
-(void)refreshPhysicsBodyAndSetPosition:(CGPoint)position;

@end
