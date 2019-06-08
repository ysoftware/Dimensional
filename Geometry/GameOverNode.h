//
//  GameOverNode.h
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GameOverNode;
@protocol GameOverNodeDelegate
-(void)gameOverRestart;
-(void)gameOverQuit;
@end

@interface GameOverNode : SKSpriteNode
@property (nonatomic, weak) id delegate;
-(instancetype)initWithTitle:(NSString*)titleText;
@end
