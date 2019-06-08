//
//  BackgroundNode.h
//  Dimensional
//
//  Created by Ярослав Ерохин on 23.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BackgroundNode : SKSpriteNode
-(void)switchColorsForLevel:(NSInteger)level;
-(SKColor*)colorForLevel:(NSInteger)level;
-(void)scaleTo:(float)scale withDuration:(float)duration;
- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size andCirclesNode:(SKNode*)node;
@end
