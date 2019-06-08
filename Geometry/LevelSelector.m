//
//  LevelSelector.m
//  Geometry
//
//  Created by Ярослав Ерохин on 07.11.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "LevelSelector.h"
#import "SKButton.h"
#import "MainView.h"

@implementation LevelSelector{
    NSString *selectedLevel;
    SKNode *rootLevelSelectorNode;
    SKSpriteNode *playerIconNode;
    SKButton *forwardButton, *backButton, *playButton1, *playButton2, *playButton3, *playButton4, *playButton5, *playButton6, *playButton7, *playButton8, *playButton9;
    BOOL levelLoaded;
    NSArray *levelNames;
    SKAction *playerRotateBack;
    MainView *mainView;
}

@synthesize chapterId;

#pragma mark - Scene life cycle

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self){
        self.backgroundColor = [SKColor clearColor];
        levelNames = @[@"Rising Tide", @"Green Hunt", @"Early Sundown", @"Deep Night", @"Winter doubt"];

        rootLevelSelectorNode = [self.scene childNodeWithName:@"levelSelectorNode"];
        rootLevelSelectorNode.alpha = 0;
        playerIconNode = (SKSpriteNode*)[self.scene childNodeWithName:@"playerIcon"];
        playerIconNode.color = [SKColor colorWithRed:1 green:1 blue:1 alpha:.25];

        playerRotateBack = [SKAction rotateToAngle:DEGREES_TO_RADIANS(27) duration:.1];
        playerRotateBack.timingMode = SKActionTimingEaseOut;
    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    mainView = (MainView*)self.view;
    [self animateIn];
    [self animateUI];
    
    //Chapter settings
    [self.backgroundNode switchColorsForChapterNamed:chapterId];

    [self setUpButtons];
    SKLabelNode *chapterLabel = (SKLabelNode*)[rootLevelSelectorNode childNodeWithName:@"chapterLabelButton"];
    SKLabelNode *titleLabel = (SKLabelNode*)[rootLevelSelectorNode childNodeWithName:@"titleLabelButton"];

    chapterLabel.text = [NSString stringWithFormat:@"CHAPTER %ld", (long)[chapterId integerValue]];
    titleLabel.text = levelNames[[chapterId intValue]-1];

    //level buttons
    if (forwardButton){
        [rootLevelSelectorNode addChild:forwardButton];
    }
    [rootLevelSelectorNode addChild:backButton];
    [rootLevelSelectorNode addChild:playButton1];
    [rootLevelSelectorNode addChild:playButton2];
    [rootLevelSelectorNode addChild:playButton3];
    [rootLevelSelectorNode addChild:playButton4];
    [rootLevelSelectorNode addChild:playButton5];
    [rootLevelSelectorNode addChild:playButton6];
    [rootLevelSelectorNode addChild:playButton7];
    [rootLevelSelectorNode addChild:playButton8];
    [rootLevelSelectorNode addChild:playButton9];

}

#pragma mark - Animations

-(void)animateToLevelWithButton:(SKButton*)sender{
    [rootLevelSelectorNode enumerateChildNodesWithName:@"*Button*" usingBlock:^(SKNode *node, BOOL *stop) {
        node.userInteractionEnabled = NO;
        if (![node isEqual:sender]){
            SKAction *fadeOut = [SKAction fadeOutWithDuration:.2];
            [node runAction:fadeOut];
        }
    }];

    SKAction *levelMove = [SKAction moveTo:CGPointZero duration:.4];
    SKAction *levelScale1 = [SKAction scaleTo:.75 duration:.4];
    SKAction *levelScale2 = [SKAction scaleTo:15 duration:.6];
    SKAction *levelFadeOut = [SKAction fadeOutWithDuration:.6];
    levelScale2.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *levelAnimations = [SKAction sequence:@[[SKAction group:@[levelMove, levelScale1]], [SKAction group:@[levelScale2, levelFadeOut]]]];
    [sender runAction:levelAnimations];

    SKAction *playerScaleDown1 = [SKAction scaleTo:3 duration:.2];
    SKAction *playerScaleUp1 = [SKAction scaleTo:4 duration:.3];
    SKAction *playerScaleDown2 = [SKAction resizeToWidth:40 height:40 duration:.5];
    SKAction *playerMove = [SKAction moveTo:CGPointZero duration:.8];
    SKAction *playerFadeIn = [SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1 duration:.8];
    SKAction *playerRotate = [SKAction rotateToAngle:0 duration:.8];
    SKAction *playerAnimations = [SKAction sequence:@[playerScaleDown1,
                                                      [SKAction runBlock:^{playerIconNode.zPosition = 4;}],
                                                      [SKAction group:@[playerMove, [SKAction sequence:@[playerScaleUp1, playerScaleDown2]], playerFadeIn, playerRotate]]]];
    playerAnimations.timingMode = SKActionTimingEaseInEaseOut;

    [self.backgroundNode scaleTo:1.2 withDuration:1];
    [playerIconNode removeAllActions];
    [playerIconNode runAction:playerAnimations completion:^{
        [mainView switchToLevelSceneWithChapterId:chapterId andLevelId:selectedLevel];
    }];
}

-(void)animateIn{
        [rootLevelSelectorNode setScale:.2];
        SKAction *scale = [SKAction scaleTo:1 duration:.2];
        SKAction *fade = [SKAction fadeInWithDuration:.2];
        SKAction *animation = [SKAction group:@[scale, fade]];
        [rootLevelSelectorNode runAction:animation];
}

-(void)animateUI{
    //animate playerIcon
    SKAction *rotate1 = [SKAction rotateByAngle:DEGREES_TO_RADIANS(5) duration:1];
    SKAction *rotate1Back = [SKAction rotateToAngle:DEGREES_TO_RADIANS(27) duration:.2];
    rotate1Back.timingMode = SKActionTimingEaseOut;
    SKAction *rotate2 = [SKAction rotateByAngle:DEGREES_TO_RADIANS(15) duration:3];
    SKAction *rotate2Back = [SKAction rotateToAngle:DEGREES_TO_RADIANS(27) duration:.2];
    rotate2Back.timingMode = SKActionTimingEaseOut;
    SKAction *rotate3 = [SKAction rotateByAngle:DEGREES_TO_RADIANS(45) duration:3];
    SKAction *rotate3Back = [SKAction rotateToAngle:DEGREES_TO_RADIANS(27) duration:.2];
    rotate3Back.timingMode = SKActionTimingEaseOut;
    SKAction *rotate4 = [SKAction rotateByAngle:DEGREES_TO_RADIANS(25) duration:2];
    SKAction *rotate4Back = [SKAction rotateToAngle:DEGREES_TO_RADIANS(27) duration:.2];
    rotate4Back.timingMode = SKActionTimingEaseOut;
    SKAction *playerButtonAnimations = [SKAction repeatActionForever:[SKAction sequence:@[rotate1, rotate1Back, rotate2, rotate2Back, rotate3, rotate3Back, rotate4, rotate4Back]]];
    [playerIconNode runAction:playerButtonAnimations];
}

#pragma mark - Actions
-(void)backButtonClick{
    SKAction *scale = [SKAction scaleTo:.2 duration:.2];
    SKAction *fade = [SKAction fadeOutWithDuration:.2];
    SKAction *animation = [SKAction group:@[scale, fade]];
    if ([chapterId isEqualToString:@"01"]){
        [self.backgroundNode scaleTo:.7 withDuration:.6];
        [playerIconNode removeAllActions];
        [playerIconNode runAction:playerRotateBack completion:^{
            [rootLevelSelectorNode runAction:animation completion:^{
                [mainView switchToMainMenuSceneWithAnimationInForward:NO];
            }];
        }];
    }
    else{
        NSInteger newIntegerchapterId = [chapterId integerValue];
        newIntegerchapterId--;
        NSString *format = newIntegerchapterId>9 ? @"%ld" : @"0%ld";
        NSString *newChapter = [NSString stringWithFormat:format, newIntegerchapterId];

        [self.backgroundNode scaleTo:.8+[newChapter floatValue]*.03 withDuration:.6];
        [playerIconNode removeAllActions];
        [playerIconNode runAction:playerRotateBack completion:^{
            [rootLevelSelectorNode runAction:animation completion:^{
                [mainView switchToLevelSelectorWithAnimationInForward:NO andChapterId:newChapter];
            }];
        }];
    }
}

-(void)forwardButtonClick{
    SKAction *scale = [SKAction scaleTo:3 duration:.2];
    SKAction *fade = [SKAction fadeOutWithDuration:.2];
    SKAction *animation = [SKAction group:@[scale, fade]];
    NSInteger newIntegerchapterId = [chapterId integerValue];
    newIntegerchapterId++;
    NSString *format = newIntegerchapterId>9 ? @"%ld" : @"0%ld";
    NSString *newChapter = [NSString stringWithFormat:format, newIntegerchapterId];

    [self.backgroundNode scaleTo:.8+[newChapter floatValue]*.03 withDuration:.6];
    [playerIconNode removeAllActions];
    [playerIconNode runAction:playerRotateBack completion:^{
        [rootLevelSelectorNode runAction:animation completion:^{
            [mainView switchToLevelSelectorWithAnimationInForward:YES andChapterId:newChapter];
        }];
    }];
}

#pragma mark - Buttons actions

-(void)playButton1Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"01";
    [self animateToLevelWithButton:playButton1];
}

-(void)playButton2Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"02";
    [self animateToLevelWithButton:playButton2];
}

-(void)playButton3Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"03";
    [self animateToLevelWithButton:playButton3];
}

-(void)playButton4Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"04";
    [self animateToLevelWithButton:playButton4];
}

-(void)playButton5Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"05";
    [self animateToLevelWithButton:playButton5];
}

-(void)playButton6Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"06";
    [self animateToLevelWithButton:playButton6];
}

-(void)playButton7Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"07";
    [self animateToLevelWithButton:playButton7];
}

-(void)playButton8Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"08";
    [self animateToLevelWithButton:playButton8];
}

-(void)playButton9Click{
    if (levelLoaded){
        return;
    }
    levelLoaded = YES;
    selectedLevel = @"09";
    [self animateToLevelWithButton:playButton9];
}

-(void)setUpButtons{
    //back and forward buttons
    backButton = [[SKButton alloc] initWithTexture:[[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"playButton"] colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
    backButton.size = CGSizeMake(80, 80);
    backButton.position = CGPointMake(-400, -100);
    backButton.zPosition = 2;
    backButton.xScale = -1;
    [backButton setTouchUpInsideTarget:self action:@selector(backButtonClick)];
    backButton.name = @"backButton";

    if ([chapterId integerValue] != GAME_CHAPTERS_COUNT){
        forwardButton = [[SKButton alloc] initWithTexture:[[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"playButton"] colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
        forwardButton.size = CGSizeMake(80, 80);
        forwardButton.position = CGPointMake(400, -100);
        forwardButton.zPosition = 2;
        [forwardButton setTouchUpInsideTarget:self action:@selector(forwardButtonClick)];
        forwardButton.name = @"forwardButton";
    }

    //level buttons
    playButton1 =  [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@01", chapterId]]
                                                  selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@01_selected", chapterId]]];
    [playButton1 setPosition:CGPointMake(-220, 50)];
    playButton1.size = CGSizeMake(200, 130);
    playButton1.zPosition = 2;
    [playButton1 setTouchUpInsideTarget:self action:@selector(playButton1Click)];
    playButton1.name = @"playButton1";

    playButton2 =  [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@02", chapterId]]
                                                  selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@02_selected", chapterId]]];
    [playButton2 setPosition:CGPointMake(0, 50)];
    playButton2.size = CGSizeMake(200, 130);
    playButton2.zPosition = 2;
    [playButton2 setTouchUpInsideTarget:self action:@selector(playButton2Click)];
    playButton2.name = @"playButton2";

    playButton3 =  [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@03", chapterId]]
                                                  selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@03_selected", chapterId]]];
    [playButton3 setPosition:CGPointMake(220, 50)];
    playButton3.size = CGSizeMake(200, 130);
    playButton3.zPosition = 2;
    [playButton3 setTouchUpInsideTarget:self action:@selector(playButton3Click)];
    playButton3.name = @"playButton3";


    playButton4 = [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@04", chapterId]]
                                                 selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@04_selected", chapterId]]];
    [playButton4 setPosition:CGPointMake(-220, -100)];
    playButton4.size = CGSizeMake(200, 130);
    playButton4.zPosition = 2;
    [playButton4 setTouchUpInsideTarget:self action:@selector(playButton4Click)];
    playButton4.name = @"playButton4";

    playButton5 = [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@05", chapterId]]
                                                 selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@05_selected", chapterId]]];
    [playButton5 setPosition:CGPointMake(0, -100)];
    playButton5.size = CGSizeMake(200, 130);
    playButton5.zPosition = 2;
    [playButton5 setTouchUpInsideTarget:self action:@selector(playButton5Click)];
    playButton5.name = @"playButton5";

    playButton6 = [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@06", chapterId]]
                                                 selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@06_selected", chapterId]]];
    [playButton6 setPosition:CGPointMake(220, -100)];
    playButton6.size = CGSizeMake(200, 130);
    playButton6.zPosition = 2;
    [playButton6 setTouchUpInsideTarget:self action:@selector(playButton6Click)];
    playButton6.name = @"playButton6";

    playButton7 = [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@07", chapterId]]
                                                 selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@07_selected", chapterId]]];
    [playButton7 setPosition:CGPointMake(-220, -250)];
    playButton7.size = CGSizeMake(200, 130);
    playButton7.zPosition = 2;
    [playButton7 setTouchUpInsideTarget:self action:@selector(playButton7Click)];
    playButton7.name = @"playButton7";

    playButton8 = [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@08", chapterId]]
                                                 selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@08_selected", chapterId]]];
    [playButton8 setPosition:CGPointMake(0, -250)];
    playButton8.size = CGSizeMake(200, 130);
    playButton8.zPosition = 2;
    [playButton8 setTouchUpInsideTarget:self action:@selector(playButton8Click)];
    playButton8.name = @"playButton8";

    playButton9 = [[SKButton alloc] initWithTextureNormal:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@09", chapterId]]
                                                 selected:[[SKTextureAtlas atlasNamed:@"Levels"] textureNamed:[NSString stringWithFormat:@"levelThumbnail_%@09_selected", chapterId]]];
    [playButton9 setPosition:CGPointMake(220, -250)];
    playButton9.size = CGSizeMake(200, 130);
    playButton9.zPosition = 2;
    [playButton9 setTouchUpInsideTarget:self action:@selector(playButton9Click)];
    playButton9.name = @"playButton9";
}


@end
