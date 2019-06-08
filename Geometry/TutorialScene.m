//
//  TutorialScene.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 28.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "TutorialScene.h"
#import "SKButton.h"
#import "LevelScene.h"
#import "PopoverView.h"
#import "AppDelegate.h"
#import "MainView.h"

@implementation TutorialScene{
    SKLabelNode *titleNode, *messageNode;
    SKSpriteNode *imageNode, *backgroundNode;
    NSArray *titles, *messages;
    SKButton *nextButton, *backButton;
    NSInteger screen;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [SKColor clearColor];

        //next button
        nextButton = [[SKButton alloc] initWithTexture:[[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"playButton"] colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
        [nextButton setPosition:CGPointMake(0, -220)];
        nextButton.zPosition = 2;
        nextButton.size = CGSizeMake(80, 80);

        //back button
        backButton = [[SKButton alloc] initWithTexture:[[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"playButton"] colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
        [backButton setPosition:CGPointMake(-150, -220)];
        backButton.zPosition = 2;
        backButton.zRotation = DEGREES_TO_RADIANS(-180);
        backButton.size = CGSizeMake(60, 60);
        [backButton setTouchUpInsideTarget:self action:@selector(goBack)];

        titles = @[@"Welcome to Dimensional", @"Fight the majority", @"Know your enemy", @"Start the clock"];
        messages = @[@"A world where everyshape hates you", @"Use your fingers to control yourshape", @"Collect bonuses from destroyed shapes", @"Your time is limited. Get ready!"];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    //nodes
    backgroundNode = (SKSpriteNode*)[self.scene childNodeWithName:@"Background"];
    titleNode = (SKLabelNode*)[backgroundNode childNodeWithName:@"TitleText"];
    messageNode = (SKLabelNode*)[backgroundNode childNodeWithName:@"MessageText"];
    imageNode = (SKSpriteNode*)[backgroundNode childNodeWithName:@"Image"];

    [self.scene addChild:nextButton];
    [self setUp];
}

-(void)setUp{
    titleNode.text = titles[screen];
    messageNode.text = messages[screen];
    imageNode.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"TutorialMessage%ld", (long)screen]];

    //first screen
    if (screen == 0){
        //next button
        [nextButton runAction:[SKAction moveTo:CGPointMake(0, -220) duration:.2]];

        //back button
        if (backButton.parent){
            [backButton runAction:[SKAction fadeOutWithDuration:.2] completion:^{
                [backButton removeFromParent];
            }];
        }
    }
    else{
        //next button
        [nextButton runAction:[SKAction moveTo:CGPointMake(150, -220) duration:.2]];

        //back button
        if (!backButton.parent){
            [self.scene addChild:backButton];
        }
        [backButton runAction:[SKAction fadeInWithDuration:.2]];
    }

    //button actions
    if (screen == titles.count-1){
        [nextButton setTouchUpInsideTarget:self action:@selector(unPauseButtonClick)];
    }
    else{
        [nextButton setTouchUpInsideTarget:self action:@selector(goForward)];
    }
}

#pragma mark - Buttons

-(void)unPauseButtonClick{
}

-(void)goBack{
    SKAction *moveAndFadeOut = [SKAction group:@[[SKAction moveBy:CGVectorMake(150, 0) duration:.1], [SKAction fadeOutWithDuration:.1]]];
    SKAction *positionSwitch = [SKAction moveBy:CGVectorMake(-300, 0) duration:.1];
    SKAction *moveAndFadeIn = [SKAction group:@[[SKAction moveBy:CGVectorMake(150, 0) duration:.1], [SKAction fadeInWithDuration:.1]]];
    SKAction *animations = [SKAction sequence:@[moveAndFadeOut, positionSwitch]];

    if (screen>0){
        screen--;
        [backgroundNode runAction:animations completion:^{
            [self setUp];
            [backgroundNode runAction:moveAndFadeIn];
        }];
    }
}

-(void)goForward{
    SKAction *moveAndFadeOut = [SKAction group:@[[SKAction moveBy:CGVectorMake(-150, 0) duration:.1], [SKAction fadeOutWithDuration:.1]]];
    SKAction *positionSwitch = [SKAction moveBy:CGVectorMake(300, 0) duration:.1];
    SKAction *moveAndFadeIn = [SKAction group:@[[SKAction moveBy:CGVectorMake(-150, 0) duration:.1], [SKAction fadeInWithDuration:.1]]];
    SKAction *animations = [SKAction sequence:@[moveAndFadeOut, positionSwitch]];

    if (screen<titles.count){
        screen++;
        [backgroundNode runAction:animations completion:^{
            [self setUp];
            [backgroundNode runAction:moveAndFadeIn];
        }];
    }
}

@end
