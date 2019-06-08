//
//  LevelPassedNode.h
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class LevelPassedNode;

@protocol LevelPassedNodeDelegate
-(void)levelPassedRestart;
-(void)levelPassedQuit;
@end

@interface LevelPassedNode : SKSpriteNode
@property (weak, nonatomic) id delegate;

-(instancetype)initWithScore:(NSInteger)currentScore;
@end
