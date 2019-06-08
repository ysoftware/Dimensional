//
//  PauseNode.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "PauseNode.h"
#import "SKButton.h"
#import "MainView.h"

@implementation PauseNode{
    SKButton *playButton, *restartButton, *toMainMenuButton;
    BOOL someGamepadButtonPressed;
}

@synthesize delegate;

#pragma mark - Game controller methods

-(void)setupControllers{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
[appDelegate gamepadResetButtonsHandlers];
    
    NSString *texture_mod;
    if (appDelegate.currentController){
        someGamepadButtonPressed = NO;
        __unsafe_unretained typeof(self) weakSelf = self;
        appDelegate.currentController.controllerPausedHandler = ^(GCController *controller){
            [weakSelf resume];};
        appDelegate.currentController.extendedGamepad.buttonA.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed && !self->someGamepadButtonPressed){ self->someGamepadButtonPressed = YES; self->playButton.isSelected = YES; } else { [self resume]; }};
        appDelegate.currentController.extendedGamepad.buttonY.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed && !self->someGamepadButtonPressed){ self->someGamepadButtonPressed = YES; self->toMainMenuButton.isSelected = YES; } else { [self quit]; }};
        appDelegate.currentController.extendedGamepad.buttonX.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed && !self->someGamepadButtonPressed){ self->someGamepadButtonPressed = YES; self->restartButton.isSelected = YES; } else { [self restart]; }};
        appDelegate.currentController.extendedGamepad.buttonB.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (!pressed) { [self resume]; }};

        texture_mod = @"-gamepad";
    }
    else{
        texture_mod = @"";
    }

    playButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"playButton%@", texture_mod]];
    restartButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"restartButton%@", texture_mod]];
    toMainMenuButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"cancelButton%@", texture_mod]];
}

#pragma mark - Node life cycle

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)init{
    CGSize size = CGSizeMake(900, 650);
    if (IS_IPHONE) size = CGSizeMake(1024, 683);
    
    self = [super initWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:.85] size:size];
    if (self){
        self.zPosition = 9;
        self.name = @"PauseNode";

        AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        SKLabelNode *titleLabelNode = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
        titleLabelNode.fontSize = appDelegate.largeFontSize;
        titleLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        titleLabelNode.text = [NSLocalizedString(@"pause_title", @"Pause Menu title") uppercaseString];;
        titleLabelNode.position = CGPointMake(0, 0);
        [self addChild:titleLabelNode];

        //resume button
        playButton = [[SKButton alloc] initWithImageNamed:@"playButton" colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
        [playButton setPosition:CGPointMake(358, -211)];
        playButton.zPosition = 2;
        playButton.size = CGSizeMake(96, 96);
        [playButton setTouchUpInsideTarget:self action:@selector(resume)];
        [self addChild:playButton];

        //restart level button
        restartButton = [[SKButton alloc] initWithImageNamed:@"restartButton" colorNormal:UI_COLOR_ORANGE_STAY_NORMAL colorSelected:UI_COLOR_ORANGE_STAY_SELECTED];
        [restartButton setPosition:CGPointMake(-358, -211)];
        restartButton.zPosition = 2;
        restartButton.size = CGSizeMake(96, 96);
        [restartButton setTouchUpInsideTarget:self action:@selector(restart)];
        [self addChild:restartButton];

        //back to main menu button
        toMainMenuButton = [[SKButton alloc] initWithImageNamed:@"cancelButton" colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
        [toMainMenuButton setPosition:CGPointMake(-358, 218)];
        toMainMenuButton.size = CGSizeMake(75, 75);
        [toMainMenuButton setTouchUpInsideTarget:self action:@selector(quit)];
        toMainMenuButton.zPosition = 2;
        [self addChild:toMainMenuButton];

        //animation
        [self setAlpha:0];
        [self runAction:[SKAction scaleTo:2 duration:0]];
        SKAction *animation = [SKAction group:@[[SKAction fadeInWithDuration:.2], [SKAction scaleTo:1 duration:.2]]];
        animation.timingMode = UIViewAnimationCurveEaseOut;
        [self runAction:animation];

        //set up
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers) name:NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED object:nil];
        [self setupControllers];
    }
    return self;
}

#pragma mark - Delegate calls

-(void)resume{    
    [self runAction:[SKAction fadeOutWithDuration:.2] completion:^{
        [self removeFromParent];
        if ([self->delegate respondsToSelector:@selector(pauseResume)]){
            [self->delegate pauseResume];
        }
    }];
}

-(void)quit{
    [self removeFromParent];
    if ([delegate respondsToSelector:@selector(pauseQuit)]){
        [delegate pauseQuit];
    }
}

-(void)restart{
    [self removeFromParent];
    if ([delegate respondsToSelector:@selector(pauseRestart)]){
        [delegate pauseRestart];
    }
}

@end
