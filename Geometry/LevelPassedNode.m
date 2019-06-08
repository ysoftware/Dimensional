//
//  LevelPassedNode.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "LevelPassedNode.h"
#import "GameCenterManager.h"
#import "SKButton.h"
#import "MainView.h"

@implementation LevelPassedNode{
    NSInteger score;
    MainView *mainView;
    SKButton *restartButton, *quitButton;
    BOOL someGamepadButtonPressed;
    SKLabelNode *scoreStatic, *scoreLabel, *highScoreLabel;
    float animationDelay;
}

@synthesize delegate;

#pragma mark - Game controller methods

-(void)setupControllers{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate gamepadResetButtonsHandlers];

    if (appDelegate.currentController){
        someGamepadButtonPressed = NO;
        __unsafe_unretained typeof(self) weakSelf = self;
        appDelegate.currentController.controllerPausedHandler = ^(GCController *controller){
            [weakSelf restartLevel]; };
        appDelegate.currentController.extendedGamepad.buttonA.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed && !self->someGamepadButtonPressed){ self->someGamepadButtonPressed = YES; self->restartButton.isSelected = YES; } else { [self restartLevel]; }};
        appDelegate.currentController.extendedGamepad.buttonX.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed && !self->someGamepadButtonPressed){ self->someGamepadButtonPressed = YES; self->restartButton.isSelected = YES; } else { [self restartLevel]; }};
        appDelegate.currentController.extendedGamepad.buttonB.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
            if (pressed && !self->someGamepadButtonPressed){ self->someGamepadButtonPressed = YES; self->quitButton.isSelected = YES; } else { [self quit]; }};
        appDelegate.currentController.extendedGamepad.buttonY.pressedChangedHandler = nil;

        quitButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"cancelButtonB-gamepad"];
        restartButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"restartButtonA-gamepad"];
    }
    else{
        quitButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"cancelButton"];
        restartButton.texture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"restartButton"];
    }
}

#pragma mark - Node life cycle

-(instancetype)initWithScore:(NSInteger)currentScore{
    CGSize size = CGSizeMake(900, 650);
    if (IS_IPHONE) size = CGSizeMake(1024, 683);

    self = [super initWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:.85] size:size];
    if (self) {
        self.delegate = delegate;
        score = currentScore;
        self.name = @"LevelPassedNode";
        animationDelay = .2;
        self.zPosition = 8;

        AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

        //background node
        SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
        titleNode.position = CGPointMake(0, 218);
        titleNode.text = [[self scoreDependentTitleText] uppercaseString];
        titleNode.fontSize = appDelegate.largeFontSize;
        if (titleNode.text.length>30)
            titleNode.fontSize = appDelegate.mediumFontSize;
        [self addChild:titleNode];

        scoreStatic = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
        scoreStatic.position = CGPointMake(0, 146);
        scoreStatic.fontSize = appDelegate.defaultFontSize;
        scoreStatic.text = [NSLocalizedString(@"levelpassed_score_title", @"'You scored' title in the Game Over Menu") uppercaseString];
        [self addChild:scoreStatic];

        scoreLabel = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
        scoreLabel.position = CGPointMake(0, 96);
        scoreLabel.fontSize = appDelegate.largeFontSize;
        [self addChild:scoreLabel];

        highScoreLabel = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
        highScoreLabel.position = CGPointMake(0, 65);
        highScoreLabel.fontColor = FONT_COLOR_NEW_HIGHSCORE;
        highScoreLabel.text = [NSLocalizedString(@"levelpassed_newhighscore_title", @"'New Highscore' title in the Game Over Menu") uppercaseString];
        highScoreLabel.fontSize = appDelegate.defaultFontSize;
        [self addChild:highScoreLabel];

        //restart level button
        restartButton = [[SKButton alloc] initWithImageNamed:@"restartButton" colorNormal:UI_COLOR_ORANGE_STAY_NORMAL colorSelected:UI_COLOR_ORANGE_STAY_SELECTED];
        [restartButton setPosition:CGPointMake(358, -211)];
        restartButton.size = CGSizeMake(96, 96);
        restartButton.zPosition = 2;
        [restartButton setTouchUpInsideTarget:self action:@selector(restartLevel)];
        [self addChild:restartButton];

        //next button
        quitButton = [[SKButton alloc] initWithImageNamed:@"cancelButton" colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
        [quitButton setPosition:CGPointMake(-358, 218)];
        quitButton.zPosition = 2;
        quitButton.size = CGSizeMake(75, 75);
        [quitButton setTouchUpInsideTarget:self action:@selector(quit)];
        [self addChild:quitButton];

        //ANIMATING LABELS
        scoreLabel.position = CGPointMake(0, scoreLabel.position.y-25);
        scoreStatic.position = CGPointMake(0, scoreStatic.position.y-25);

        highScoreLabel.alpha = 0;
        scoreLabel.alpha = 0;
        scoreStatic.alpha = 0;

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setGroupingSeparator:@","];
        [formatter setGroupingSize:3];
        [formatter setUsesGroupingSeparator:YES];

        [scoreLabel animateTextWithFormat:nil usingNumbersFrom:0 To:score withDuration:1 usingNumberFormatter:formatter andCompletionBlock:nil];
        SKAction *animateScoreLabel2 = [SKAction sequence:@[[SKAction fadeInWithDuration:.1], [SKAction moveByX:0 y:25 duration:.3]]];
        [scoreLabel runAction:[SKAction sequence:@[[SKAction waitForDuration:.2], animateScoreLabel2]]];
        [scoreStatic runAction:animateScoreLabel2];

        //set up
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers) name:NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED object:nil];
        [self setupControllers];
        [self gameCenterUpdate];
        [self updateAchievements];

        //animation
        [self setAlpha:0];
        [self runAction:[SKAction scaleTo:2 duration:0]];
        SKAction *animation = [SKAction group:@[[SKAction fadeInWithDuration:.2], [SKAction scaleTo:1 duration:.2]]];
        animation.timingMode = UIViewAnimationCurveEaseOut;
        [self runAction:animation];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString*)scoreDependentTitleText{
    NSString *scoreDependentTitle;
    if (score == 0){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_0", @"Game Over Menu title");
        return scoreDependentTitle;}
    else if (score == 42){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_42", nil);
        return scoreDependentTitle;}
    else if (score < 100){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_100", nil);
        return scoreDependentTitle;}
    else if (score < 500){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_500", nil);
        return scoreDependentTitle;}
    else if (score < 5000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_5k", nil);
        return scoreDependentTitle;}
    else if (score < 15000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_15k", nil);
        return scoreDependentTitle;}
    else if (score < 50000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_50k", nil);
        return scoreDependentTitle;}
    else if (score < 100000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_100k", nil);
        return scoreDependentTitle;}
    else if (score < 500000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_500k", nil);
        return scoreDependentTitle;}
    else if (score < 1000000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_1m", nil);
        return scoreDependentTitle;}
    else if (score < 5000000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_5m", nil);
        return scoreDependentTitle;}
    else if (score < 10000000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_10m", nil);
        return scoreDependentTitle;}
    else if (score < 50000000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_50m", nil);
        return scoreDependentTitle;}
    else if (score > 50000000){
        scoreDependentTitle = NSLocalizedString(@"levelpassed_title_infinity", nil);
        return scoreDependentTitle;}
    else
        return NSLocalizedString(@"levelpassed_title", @"Game Over Menu title");
}

-(BOOL)shouldShowAds{
    //проверить, не отключена ли реклама
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Dimensional.Ads.Remove"] == nil;
}

#pragma mark - Game Center methods

-(void)inviteFriends{

}

-(void)updateAchievements{
    if ([[GameCenterManager sharedManager] checkGameCenterAvailability]){
        if (score==0)
            [[GameCenterManager sharedManager] saveAndReportAchievement:@"noPoints" percentComplete:100. shouldDisplayNotification:YES];
        if (score>100000)
            [[GameCenterManager sharedManager] saveAndReportAchievement:@"score100k" percentComplete:100. shouldDisplayNotification:YES];
        if (score>500000)
            [[GameCenterManager sharedManager] saveAndReportAchievement:@"score500k" percentComplete:100. shouldDisplayNotification:YES];
        if (score>5000000)
            [[GameCenterManager sharedManager] saveAndReportAchievement:@"score5m" percentComplete:100. shouldDisplayNotification:YES];

        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSInteger enemiesKilledTotal = [settings integerForKey:USERDEFAULTS_ENEMIES_KILLED_TOTAL];

        float kill5kProgress = [[GameCenterManager sharedManager] progressForAchievement:@"kill5k"];
        float kill50kProgress = [[GameCenterManager sharedManager] progressForAchievement:@"kill50k"];
        float kill500kProgress = [[GameCenterManager sharedManager] progressForAchievement:@"kill500k"];

        kill5kProgress += 100./5000.*enemiesKilledTotal;
        kill50kProgress += 100./50000.*enemiesKilledTotal;
        kill500kProgress += 100./500000.*enemiesKilledTotal;

        [[GameCenterManager sharedManager] saveAndReportAchievement:@"kill5k" percentComplete:kill5kProgress shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"kill50k" percentComplete:kill50kProgress shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"kill500k" percentComplete:kill500kProgress shouldDisplayNotification:YES];

        [settings setInteger:0 forKey:USERDEFAULTS_ENEMIES_KILLED_TOTAL];
        [settings synchronize];
    }
}

-(void)gameCenterUpdate{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    if ([[GameCenterManager sharedManager] checkGameCenterAvailability]){

        NSString *leaderboardIdentifier = @"endless1";

        //REPORT NEW SCORE
        GKScore *newScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
        newScore.value = score;
        [GKScore reportScores:@[newScore] withCompletionHandler:^(NSError *error) {
            if (error){
#ifdef DEBUG
                NSLog(@"levelPassedNode: score report error: %@", error.localizedDescription);
#endif
            }
        }];

        //LOAD ALL SCORES
        GKLeaderboard *globalLeaderboard = [[GKLeaderboard alloc] init];
        globalLeaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
        globalLeaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
        globalLeaderboard.identifier = leaderboardIdentifier;
        globalLeaderboard.range = NSMakeRange(1, 6);
        [globalLeaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            if (error){
#ifdef DEBUG
                NSLog(@"levelPassedNode: global leaderboard loading error: %@", error.localizedDescription);
#endif
                return;
            }

            //            NSMutableArray *global = [scores mutableCopy];
            //            GKScore *myScore = globalLeaderboard.localPlayerScore;
            //            if (myScore){
            //                if (![global containsObject:myScore] || global.count>5){
            //                    [global replaceObjectAtIndex:global.count-1 withObject:myScore];
            //                }
            //                else{
            //                    [global addObject:myScore];
            //                }
            //            }

            GKScore *myScore = globalLeaderboard.localPlayerScore;
            if (self->score > myScore.value){
                [self->highScoreLabel runAction:[SKAction fadeInWithDuration:.3]];
            }

            [self showTableWithScores:scores];
        }];
    }
    else{
#ifdef DEBUG
        NSLog(@"LevelPassedNode: Game Center not available");
#endif
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
        title.text = NSLocalizedString(@"levelpassed_gamecenter_signin_title", nil);
        title.fontSize = appDelegate.defaultFontSize;
        title.position = CGPointMake(0, -150);
        [self addChild:title];
        title.alpha = 0;
        [title runAction:[SKAction fadeInWithDuration:1.5]];
    }
}

-(void)showTableWithScores:(NSArray*)array{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    SKAction *fadeInAction = [SKAction fadeInWithDuration:animationDelay];

    if (array.count>0){

        float defaultY = (6-(float)array.count)*15*-1;
        //TITLE LABEL
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
        title.text = [NSLocalizedString(@"levelpassed_leaderboard_title", @"Title of the leaderboard in the Game Over Menu") uppercaseString];
        title.fontSize = appDelegate.largeFontSize;
        title.position = CGPointMake(0, defaultY-10);
        [self addChild:title];
        title.alpha = 0;
        [title runAction:fadeInAction];

        for (int i=0; i<array.count; i++){
            GKScore *thisScore = array[i];
            SKNode *line = [SKNode node];
            [self addChild:line];

            //RANK LABEL
            SKLabelNode *rank = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
            rank.text = [NSString stringWithFormat:@"#%ld", (long)thisScore.rank];
            rank.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            rank.position = CGPointMake(-165, defaultY-55-40*i);

            //LONG NAME CUT OFF
            NSString *displayName = [thisScore.player.displayName copy];
            if (displayName.length > 25)
                displayName = [NSString stringWithFormat:@"%@…", [displayName substringWithRange:NSMakeRange(0, 25)]];

            //NAME LABEL
            SKLabelNode *name = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
            name.text = displayName;
            name.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            name.position = CGPointMake(-160, defaultY-55-40*i);

            //VALUE LABEL
            SKLabelNode *value = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
            value.text = thisScore.formattedValue;
            value.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            value.position = CGPointMake(70, defaultY-55-40*i);

            CGFloat fontSize; SKColor *fontColor;
            if ([thisScore.player.playerID isEqualToString:[GameCenterManager sharedManager].localPlayerId]){
                fontColor = FONT_COLOR_LEADERBOARD_ME; fontSize = appDelegate.mediumFontSize;
                if (score > thisScore.value) {
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setGroupingSeparator:@","];
                    [formatter setGroupingSize:3];
                    [formatter setUsesGroupingSeparator:YES];
                    value.text = [formatter stringFromNumber:[NSNumber numberWithInteger:score]];
                }
            }
            else if (thisScore.player.isFriend){
                fontColor = FONT_COLOR_LEADERBOARD_FRIEND; fontSize = appDelegate.defaultFontSize; }
            else{
                fontColor = FONT_COLOR_LEADERBOARD_1;fontSize = appDelegate.defaultFontSize;}

            rank.fontColor = fontColor; name.fontColor = fontColor; value.fontColor = fontColor;
            rank.fontSize = fontSize; name.fontSize = fontSize; value.fontSize = fontSize;

            [line addChild:rank]; [line addChild:name]; [line addChild:value];

            SKAction *disappear = [SKAction group:@[[SKAction fadeOutWithDuration:0], [SKAction scaleTo:5 duration:0]]];
            [line runAction:disappear];

            float delay = animationDelay + i*.3;
            SKAction *appear = [SKAction sequence:@[[SKAction waitForDuration:delay],
                                                    [SKAction group:@[[SKAction scaleTo:1 duration:.25],
                                                                      [SKAction fadeInWithDuration:.25]]]]];
            [line runAction:appear];
        }
    }
}

#pragma mark - Actions

-(void)actualRestartCall{
    [self removeFromParent];
    if (delegate)
        if ([delegate respondsToSelector:@selector(levelPassedRestart)])
            [delegate levelPassedRestart];
}

-(void)actualQuitCall{
    [self removeFromParent];
    if (delegate)
        if ([delegate respondsToSelector:@selector(levelPassedQuit)])
            [delegate levelPassedQuit];
}

#pragma mark - Delegate calls

-(void)restartLevel{
    if ([self shouldShowAds]){
        GameViewController *gvc = (GameViewController*)self.scene.view.window.rootViewController;
        [gvc showAdsWithCompletionHandler:^{
            [self runAction:[SKAction fadeOutWithDuration:.2] completion:^{
                [self actualRestartCall];
            }];
        }];
    }
    else{
        [self runAction:[SKAction fadeOutWithDuration:.2] completion:^{
            [self actualRestartCall];
        }];
    }
}

-(void)quit{
    if ([self shouldShowAds]){
        GameViewController *gvc = (GameViewController*)self.scene.view.window.rootViewController;
        [gvc showAdsWithCompletionHandler:^{
            [self actualQuitCall];
        }];
    }
    else{
        [self actualQuitCall];
    }
}
@end
