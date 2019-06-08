//
//  LevelScene.h
//  Geometry
//
//  Created by Ярослав Ерохин on 10.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BackgroundNode.h"

#define Defences_Left 3

#define LevelScene_GameStatus_Initializing @"LevelScene_GameStatus_Initializing"
#define LevelScene_GameStatus_Playing @"LevelScene_GameStatus_Playing"
#define LevelScene_GameStatus_Paused @"LevelScene_GameStatus_Paused"
#define LevelScene_GameStatus_Over @"LevelScene_GameStatus_Over"

@interface LevelScene : SKScene
@property (strong, nonatomic) BackgroundNode *backgroundNode;
-(void)pause;
@end