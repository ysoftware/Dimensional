//
//  AlertNode.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "AlertNode.h"
#import "SKButton.h"
#import "MainView.h"

@implementation AlertNode{
    SKButton *okButton, *cancelButton;
}

@synthesize delegate;

#pragma mark - Game controller methods

-(void)setupControllers{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate gamepadResetButtonsHandlers];

    NSString *texture_mod;
    if (appDelegate.currentController){

        appDelegate.currentController.extendedGamepad.buttonA.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed){ self->okButton.isSelected = YES; } else { self->okButton.isSelected = NO; [self okButtonTapped]; }
        };
        appDelegate.currentController.extendedGamepad.buttonB.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed){ self->cancelButton.isSelected = YES;} else { self->cancelButton.isSelected = NO; [self cancelButtonTapped]; }
        };

        texture_mod = @"-gamepad";
    }
    else{
        texture_mod = @"";
    }

    okButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"playButton%@", texture_mod]];
    cancelButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:[NSString stringWithFormat:@"cancelButton%@", texture_mod]];
}

-(instancetype)initWithTitle:(NSString*)title{
    self = [super initWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:.95] size:CGSizeMake(700, 400)];
    if (self){
        AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        self.name = self.id;
        self.zPosition = 11;
        self.position = CGPointZero;
        self.title = title;

        SKLabelNode *titleLabelNode = [SKLabelNode labelNodeWithText:title];
        titleLabelNode.fontSize = appDelegate.defaultFontSize;
        titleLabelNode.fontName = appDelegate.defaultFontName;
        titleLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
        titleLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        titleLabelNode.position = CGPointMake(0, 100);
        [self addChild:titleLabelNode];

        SKLabelNode *defaultQNode = [SKLabelNode labelNodeWithText:[NSLocalizedString(@"alert_title", @"Do you want to continue? Title of the Alert Dialog") uppercaseString]];
        defaultQNode.fontSize = appDelegate.largeFontSize;
        defaultQNode.fontName = appDelegate.defaultFontName;
        defaultQNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
        defaultQNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [self addChild:defaultQNode];

        okButton = [[SKButton alloc] initWithImageNamed:@"playButton" colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
        [okButton setPosition:CGPointMake(100, -110)];
        okButton.size = CGSizeMake(80, 80);
        [okButton setTouchUpInsideTarget:self action:@selector(okButtonTapped)];
        [self addChild:okButton];

        cancelButton = [[SKButton alloc] initWithImageNamed:@"cancelButton" colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
        [cancelButton setPosition:CGPointMake(-100, -110)];
        cancelButton.size = CGSizeMake(80, 80);
        [cancelButton setTouchUpInsideTarget:self action:@selector(cancelButtonTapped)];
        [self addChild:cancelButton];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers) name:NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED object:nil];
        [self setupControllers];


        self.alpha = 0;
        [self runAction:[SKAction fadeInWithDuration:.15]];
    }
    return self;
}

#pragma mark - Delegate calls

-(void)okButtonTapped{
    [self runAction:[SKAction fadeOutWithDuration:.2] completion:^{
        [self removeFromParent];
        if ([self->delegate respondsToSelector:@selector(alertOKWithId:)]){
            [self->delegate alertOKWithId:self.id];
        }
    }];
}

-(void)cancelButtonTapped{
    [self runAction:[SKAction fadeOutWithDuration:.2] completion:^{
        [self removeFromParent];
        if ([self->delegate respondsToSelector:@selector(alertCancelWithId:)]){
            [self->delegate alertCancelWithId:self.id];
        }
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
