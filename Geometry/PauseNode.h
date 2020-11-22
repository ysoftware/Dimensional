//
//  PauseNode.h
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PauseNode;

@protocol PauseNodeDelegate
-(void)pauseRestart;
-(void)pauseQuit;
-(void)pauseResume;
@end

@interface PauseNode : SKSpriteNode
-(instancetype)initWithEdgeInsets:(UIEdgeInsets)safeEdges;
@property (nonatomic, weak) id delegate;
@end
