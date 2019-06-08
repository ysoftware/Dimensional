//
//  InGameMenu.m
//  Geometry
//
//  Created by Ярослав Ерохин on 10.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "InGameMenu.h"
#import "SKButton.h"
#import "LevelScene.h"
#import "MainView.h"

@implementation InGameMenu{
    SKSpriteNode *rootMenuNode;
    NSString *alertId;
    PopoverView *popoverView;
}

-(void)didMoveToView:(SKView *)view{
    self.backgroundColor = [SKColor clearColor];
    popoverView = (PopoverView*)self.view;

    //background node
    rootMenuNode = (SKSpriteNode*)[self.scene childNodeWithName:@"Background"];

    //resume button
    SKButton *playButton = [[SKButton alloc] initWithImageNamed:@"playButton" colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
    [playButton setPosition:CGPointMake(150, -100)];
    playButton.zPosition = 2;
    playButton.size = CGSizeMake(200, 200);
    [playButton setTouchUpInsideTarget:self action:@selector(unPauseButtonClick)];
    [rootMenuNode addChild:playButton];

    //restart level button
    SKButton *restartButton = [[SKButton alloc] initWithImageNamed:@"restartButton" colorNormal:UI_COLOR_ORANGE_STAY_NORMAL colorSelected:UI_COLOR_ORANGE_STAY_SELECTED];
    [restartButton setPosition:CGPointMake(-150, -100)];
    restartButton.zPosition = 2;
    restartButton.size = CGSizeMake(200, 200);
    [restartButton setTouchUpInsideTarget:self action:@selector(askToRestartLevel)];
    [rootMenuNode addChild:restartButton];

    //back to main menu button
    SKButton *toMainMenuButton = [[SKButton alloc] initWithImageNamed:@"cancelButton" colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
    [toMainMenuButton setPosition:CGPointMake(-380, 255)];
    toMainMenuButton.size = CGSizeMake(100, 100);
    [toMainMenuButton setTouchUpInsideTarget:self action:@selector(askToBackToMainMenu)];
    toMainMenuButton.zPosition = 2;
    [rootMenuNode addChild:toMainMenuButton];
}

#pragma mark - Buttons

-(void)unPauseButtonClick{
}

-(void)backToMainMenuButtonClick{
}

-(void)restartLevel{
}

-(void)askToBackToMainMenu{
    alertId = Alert_LeaveTheGame;
}

-(void)askToRestartLevel{
    alertId = Alert_RestartLevel;
}

-(void)okButtonTapped{
    if ([alertId isEqualToString:Alert_LeaveTheGame]){
        [self backToMainMenuButtonClick];
    }
    else if ([alertId isEqualToString:Alert_RestartLevel]){
        [self restartLevel];
    }
}

-(void)cancelButtonTapped{
    
}

@end