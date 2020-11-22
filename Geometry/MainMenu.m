//
//  GameScene.m
//  Geometry
//
//  Created by Ярослав Ерохин on 08.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MainMenu.h"
#import "LevelScene.h"
#import "SKButton.h"
#import "MainView.h"
#import "GameCenterManager.h"
#import "Dimensional-Swift.h"

@interface MainMenu () <SettingsNodeDelegate>

@end

@implementation MainMenu{
    SKNode *rootMainMenuNode;
    SKButton *playButton, *settingsButton, *disableAdsButton;
    MainView *mainView;

    SKTextureAtlas *gameplayAtlas, *uiAtlas;
}

#pragma mark - Game controller setup

-(void)setupControllers{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate gamepadResetButtonsHandlers];

    NSString *texture_mod;
    if (appDelegate.currentController){
        appDelegate.currentController.controllerPausedHandler = ^(GCController *controller){
            //settings? idk
            [self playButtonClick];
        };
        appDelegate.currentController.extendedGamepad.buttonA.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed){ self->playButton.isSelected = YES; } else { [self playButtonClick]; self->playButton.isSelected = NO; }};
        appDelegate.currentController.extendedGamepad.buttonB.pressedChangedHandler = nil;
        appDelegate.currentController.extendedGamepad.buttonX.pressedChangedHandler = nil;
        appDelegate.currentController.extendedGamepad.buttonY.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed){ self->settingsButton.isSelected = YES; } else { self->settingsButton.isSelected = NO; [self settingsButtonClick]; }};

        texture_mod = @"-gamepad";
    }
    else{
        texture_mod = @"";
    }

    playButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"mainMenu_playButton%@", texture_mod]];
    settingsButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"settingsButton%@", texture_mod]];
}

#pragma mark - Scene life cycle

-(instancetype)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    if (self) {
        self.anchorPoint = CGPointMake(.5, .5);
        self.physicsWorld.gravity = CGVectorMake(0, 0);

        rootMainMenuNode = [SKNode node];
        rootMainMenuNode.alpha = 0;
        [self.scene addChild: rootMainMenuNode];

        SKLabelNode *gameTitleLabel = [SKLabelNode labelNodeWithText: @"Dimensional"];
        gameTitleLabel.fontName = @"Teko Light";
        [rootMainMenuNode addChild: gameTitleLabel];

        playButton = [[SKButton alloc] initWithImageNamed: @"mainMenu_playButton"
                                              colorNormal: UI_COLOR_GREEN_NEXT_NORMAL
                                            colorSelected: UI_COLOR_GREEN_NEXT_SELECTED];
        playButton.zRotation = DEGREES_TO_RADIANS(0);
        [playButton setTouchUpInsideTarget: self action: @selector(playButtonClick)];
        playButton.zPosition = 2;
        playButton.size = CGSizeMake(200, 200);
        playButton.alpha = 0;

        settingsButton = [[SKButton alloc] initWithImageNamed: @"settingsButton"
                                                  colorNormal: UI_COLOR_BLUE_NEUTRAL_NORMAL
                                                colorSelected: UI_COLOR_BLUE_NEUTRAL_SELECTED];
        settingsButton.size = CGSizeMake(62, 60);
        settingsButton.zPosition = 2;
        settingsButton.alpha = 0;

        if (IS_IPAD) {
            gameTitleLabel.position = CGPointMake(0, 160);
            gameTitleLabel.fontSize = 180;
            playButton.position = CGPointMake(0, -25);
            playButton.size = CGSizeMake(200, 200);
        } else {
            gameTitleLabel.position = CGPointMake(0, 130);
            gameTitleLabel.fontSize = 150;
            playButton.position = CGPointMake(0, -60);
        }

        settingsButton.position = CGPointMake(-450, -(size.height/2-62));

        [settingsButton setTouchUpInsideTarget: self action: @selector(settingsButtonClick)];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(setupControllers)
                                                     name:NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED
                                                   object: nil];
        [self setupControllers];
    }
    return self;
}

- (void)sceneDidLoad {
	[super sceneDidLoad];

	[[SoundManager shared] playMenuMusic];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didMoveToView:(SKView *)view{
    [rootMainMenuNode addChild:playButton];
    [rootMainMenuNode addChild:settingsButton];
    mainView = (MainView*)self.view;

    //start animation
    gameplayAtlas = [SKTextureAtlas atlasNamed:@"Gameplay"];
    uiAtlas = [SKTextureAtlas atlasNamed:@"UI"];

    if (self.firstLoad){
        [gameplayAtlas preloadWithCompletionHandler:^{
            [self->uiAtlas preloadWithCompletionHandler:^{
                [self animateInFromStart];
            }];
        }];
    }
    else{
        [self animateInBackward];
    }
}

#pragma mark - Actions

-(void)playButtonClick{
    SettingsNode *settingsNode = (SettingsNode*)[self childNodeWithName:@"SettingsNode"];
    [settingsNode closeSettings];

    SKAction *scale = [SKAction scaleTo:3 duration:.2];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:.2];
    SKAction *animation = [SKAction group:@[scale, fadeOut]];

    [self.backgroundNode scaleTo:.8 withDuration:.6];
    [rootMainMenuNode runAction:animation completion:^{
        [self->mainView switchToLevelScene];
    }];
}

-(void)settingsButtonClick{
    [mainView presentSettingsNodeWithPosition:settingsButton.position andDelegate:self];
}

-(void)settingsDone{
    [self setupControllers];
}

#pragma mark - Animations

-(void)animateInBackward{
    [self.backgroundNode scaleTo:.7 withDuration:.4];

    [rootMainMenuNode setScale:3];
    [rootMainMenuNode runAction:[SKAction fadeOutWithDuration:0]];
    [playButton runAction:[SKAction fadeOutWithDuration:0]];

    SKAction *fadeIn = [SKAction fadeInWithDuration:.3];
    SKAction *scale = [SKAction scaleTo:1 duration:.3];
    SKAction *animation = [SKAction group:@[fadeIn, scale]];

    [rootMainMenuNode runAction:animation completion:^{
        SKAction *fadeIn = [SKAction fadeInWithDuration:.1];
        SKAction *scale = [SKAction scaleTo:1 duration:.1];
        SKAction *animation = [SKAction group:@[fadeIn, scale]];
        [self->playButton runAction:animation completion:^{
            [self->settingsButton runAction:[SKAction fadeInWithDuration:.5]];
            [self animateUI];
        }];
    }];
}

-(void)animateInFromStart{
    playButton.userInteractionEnabled = NO;
    [rootMainMenuNode setScale:.2];

    SKAction *fadeIn = [SKAction fadeInWithDuration:.5];
    SKAction *scale = [SKAction scaleTo:1 duration:.5];
    SKAction *animation = [SKAction sequence:@[[SKAction waitForDuration:.1], [SKAction group:@[fadeIn, scale]]]];

    [rootMainMenuNode runAction:animation completion:^{
        SKAction *fadeIn = [SKAction fadeInWithDuration:.2];
        SKAction *scale = [SKAction scaleTo:1 duration:.2];
        SKAction *animation = [SKAction group:@[fadeIn, scale]];
        [self->playButton runAction:animation completion:^{
            self->playButton.userInteractionEnabled = YES;
            [self->settingsButton runAction:[SKAction fadeInWithDuration:.5]];
            [self animateUI];
        }];
    }];
}

-(void)animateUI {
    //animate play button
    SKAction *breathe = [SKAction scaleTo:1.2 duration:1];
    SKAction *breathe1 = [SKAction scaleTo:1 duration:3];
    breathe.timingMode = SKActionTimingEaseInEaseOut;
    breathe1.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonAnimation = [SKAction repeatActionForever:[SKAction sequence:@[breathe, breathe1]]];
	[playButton runAction:buttonAnimation completion:^{ }];
}
@end
