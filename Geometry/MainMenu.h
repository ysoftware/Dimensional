//
//  GameScene.h
//  Geometry
//

//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BackgroundNode.h"

@interface MainMenu : SKScene
@property (assign, nonatomic) BOOL firstLoad;
@property (strong, nonatomic) BackgroundNode *backgroundNode;
@end