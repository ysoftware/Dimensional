//
//  Projectile.h
//  Geometry
//
//  Created by Ярослав Ерохин on 06.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Projectile : SKSpriteNode

@property (strong, nonatomic) NSMutableArray *containingArray;

-(instancetype)initWithPosition:(CGPoint)position andAngle:(float)angle;
-(void)moveWithDeltaTime:(float)_dt andBorderNode:(CGRect)borderFrame;
-(void)die;

@end