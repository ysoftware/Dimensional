//
//  LevelSelector.h
//  Geometry
//
//  Created by Ярослав Ерохин on 07.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BackgroundNode.h"

@interface LevelSelector : SKScene
@property (strong, nonatomic) NSString *chapterId;
@property (strong, nonatomic) BackgroundNode *backgroundNode;
@end
