//
//  GameOverNode.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "GameOverNode.h"
#import "SKButton.h"
#import "MainView.h"

@implementation GameOverNode

@synthesize delegate;

-(instancetype)initWithTitle:(NSString*)titleText{
    self = [super initWithColor:[SKColor blackColor] size:CGSizeMake(900, 650)];
    if (self) {
        self.name = @"GameOverNode";
        self.zPosition = 7;
#warning add title label
        //restart level button
        SKButton *restartButton = [[SKButton alloc] initWithImageNamed:@"restartButton" colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
        [restartButton setPosition:CGPointMake(-150, -100)];
        restartButton.size = CGSizeMake(200, 200);
        restartButton.zPosition = 2;
        [restartButton setTouchUpInsideTarget:self action:@selector(restart)];
        [self addChild:restartButton];

        //back to main menu button
        SKButton *playButton = [[SKButton alloc] initWithImageNamed:@"cancelButton" colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
        [playButton setPosition:CGPointMake(150, -100)];
        playButton.size = CGSizeMake(200, 200);
        playButton.zPosition = 2;
        [playButton setTouchUpInsideTarget:self action:@selector(quit)];
        [self addChild:playButton];

        [self setAlpha:0];
        [self runAction:[SKAction fadeInWithDuration:.3]];
    }
    return self;
}

#pragma mark - Delegate calls

-(void)restart{
    [self removeFromParent];
    if ([delegate respondsToSelector:@selector(gameOverRestart)]){
        [delegate gameOverRestart];
    }
}

-(void)quit{
    [self removeFromParent];
    if ([delegate respondsToSelector:@selector(gameOverQuit)]){
        [delegate gameOverQuit];
    }
}
@end
