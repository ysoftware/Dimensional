//
//  GameOverMenu.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 28.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "SKButton.h"
#import "GameOverMenu.h"
#import "LevelScene.h"
#import "MainView.h"

@implementation GameOverMenu
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [SKColor clearColor];

    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    //background node
    SKSpriteNode *backgroundNode = (SKSpriteNode*)[self.scene childNodeWithName:@"Background"];

    //restart level button
    SKButton *restartButton = [[SKButton alloc] initWithImageNamed:@"restartButton" colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
    [restartButton setPosition:CGPointMake(-150, -100)];
    restartButton.size = CGSizeMake(200, 200);
    restartButton.zPosition = 2;
    [restartButton setTouchUpInsideTarget:self action:@selector(restartLevel)];
    [backgroundNode addChild:restartButton];

    //back to main menu button
    SKButton *playButton = [[SKButton alloc] initWithImageNamed:@"cancelButton" colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
    [playButton setPosition:CGPointMake(150, -100)];
    playButton.size = CGSizeMake(200, 200);
    playButton.zPosition = 2;
    [playButton setTouchUpInsideTarget:self action:@selector(backToMainMenuButtonClick)];
    [backgroundNode addChild:playButton];

    SKLabelNode *titleTextNode = (SKLabelNode*)[backgroundNode childNodeWithName:@"TitleText"];
    titleTextNode.text = @"Game Over";
}

-(void)backToMainMenuButtonClick{
}

-(void)restartLevel{
}

@end
