//
//  PopoverView.m
//  Geometry
//
//  Created by Ярослав Ерохин on 10.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//
#import "AppDelegate.h"
#import "InGameMenu.h"
#import "PopoverView.h"
#import "TutorialScene.h"
#import "LevelScene.h"
#import "SKButton.h"
#import "GameOverMenu.h"
#import "MainView.h"
#import "LevelPassedScene.h"

@implementation PopoverView{
    SKSpriteNode *alertNode;
    id alertSender;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.allowsTransparency = YES;
        self.ignoresSiblingOrder = YES;
        [self setSelfHidden:YES]; // hidden when game starts
        [self addParallax];

        //DEBUG
        //        self.showsFPS = YES;
        //        self.showsDrawCount = YES;
        //        self.showsNodeCount = YES;
        //        self.showsQuadCount = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentPauseMenu:) name:PopoverView_PresentPauseMenu object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentGameOverMenu:) name:PopoverView_PresentGameOverMenu object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissMenu:) name:PopoverView_DismissPopover object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAlert:) name:Popover_PresentAlert object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTutorial:) name:Popover_PresentTutorial object:nil];
    }
    return self;
}

-(void)setSelfHidden:(BOOL)hidden{
    if (hidden){
        self.hidden = YES;
        self.scene.alpha = 0;
    }
    else{
        self.scene.alpha = 0;
        self.hidden = NO;
        SKAction *animation = [SKAction fadeInWithDuration:.5];
        animation.timingMode = SKActionTimingEaseInEaseOut;
        [self.scene removeAllActions];
        [self.scene runAction:animation];
    }
}

-(void)addParallax{
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(50);
    verticalMotionEffect.maximumRelativeValue = @(-50);
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(50);
    horizontalMotionEffect.maximumRelativeValue = @(-50);
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [self addMotionEffect:group];
}

#pragma mark - Scene Methods

-(void)dismissMenu:(NSNotification*)notification{
    [self setSelfHidden:YES];
}

-(void)presentTutorial:(NSNotification*)notification{
    TutorialScene *tutorialScene = [TutorialScene unarchiveFromFile:@"TutorialScene"];
    [self presentScene:tutorialScene];
    [self setSelfHidden:NO];
}

-(void)presentPauseMenu:(NSNotification*)notification{
    InGameMenu *menuScene = [InGameMenu unarchiveFromFile:@"InGameMenu"];
    [self presentScene:menuScene];
    [self setSelfHidden:NO];
}

-(void)presentGameOverMenu:(NSNotification*)notification{
    if ([notification.userInfo[@"gameState"] isEqualToString:LevelScene_GameStatus_Died] || [notification.userInfo[@"gameState"] isEqualToString:LevelScene_GameStatus_TimeOut]){
        GameOverMenu *menuScene = [GameOverMenu unarchiveFromFile:@"GameOverScene"];
        menuScene.userInfo = notification.userInfo;
        [self presentScene:menuScene];
        [self setSelfHidden:NO];
    }
    else{
        LevelPassedScene *menuScene = [LevelPassedScene unarchiveFromFile:@"LevelPassedScene"];
        menuScene.userInfo = notification.userInfo;
        [self presentScene:menuScene];
        [self setSelfHidden:NO];
    }
}

#pragma mark - Alert Node

-(void)presentAlert:(NSNotification*)notification{
    if (!alertNode){
        NSString *title = notification.userInfo[@"title"];
        alertSender = notification.object;

        alertNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:0] size:CGSizeMake(900, 450)];
        alertNode.zPosition = 100;
        alertNode.anchorPoint = CGPointMake(.5, .5);

        SKSpriteNode *backgroundForAlertNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:0.95] size:CGSizeMake(800, 350)];
        [alertNode addChild:backgroundForAlertNode];

        SKLabelNode *titleLabelNode = [SKLabelNode labelNodeWithText:title];
        titleLabelNode.fontSize = 48;
        titleLabelNode.fontName = @"Helvetica Neue UltraLight";
        titleLabelNode.position = CGPointMake(0, 45);
        titleLabelNode.fontColor = [SKColor whiteColor];
        [alertNode addChild:titleLabelNode];

        SKColor *okColor1 = notification.userInfo[@"okColor1"];
        SKColor *okColor2 = notification.userInfo[@"okColor2"];
        SKColor *cancelColor1 = notification.userInfo[@"cancelColor1"];
        SKColor *cancelColor2 = notification.userInfo[@"cancelColor2"];

        if (!okColor1){
            okColor1 = UI_COLOR_GREEN_NEXT_NORMAL;
        }
        if (!okColor2){
            okColor2 = UI_COLOR_GREEN_NEXT_SELECTED;
        }
        if (!cancelColor1){
            cancelColor1 = UI_COLOR_RED_BACK_NORMAL;
        }
        if (!cancelColor2){
            cancelColor2 = UI_COLOR_RED_BACK_SELECTED;
        }

        SKButton *okButton = [[SKButton alloc] initWithImageNamed:@"playButton" colorNormal:okColor1 colorSelected:okColor2];
        [okButton setPosition:CGPointMake(90, -50)];
        okButton.size = CGSizeMake(100, 100);
        [okButton setTouchUpInsideTarget:self action:@selector(okButtonTapped)];
        [alertNode addChild:okButton];

        SKButton *cancelButton = [[SKButton alloc] initWithImageNamed:@"cancelButton" colorNormal:cancelColor1 colorSelected:cancelColor2];
        [cancelButton setPosition:CGPointMake(-90, -50)];
        cancelButton.size = CGSizeMake(100, 100);
        [cancelButton setTouchUpInsideTarget:self action:@selector(cancelButtonTapped)];
        [alertNode addChild:cancelButton];

        [self.scene addChild:alertNode];
    }
}

#pragma mark - Loading Scene

-(void)okButtonTapped{
    if ([alertSender respondsToSelector:@selector(okButtonTapped)]){
        [alertSender okButtonTapped];
    }

    [alertNode removeFromParent];
    alertNode = nil;
}

-(void)cancelButtonTapped{
    if ([alertSender respondsToSelector:@selector(cancelButtonTapped)]){
        [alertSender cancelButtonTapped];
    }
    
    [alertNode removeFromParent];
    alertNode = nil;
}
@end
