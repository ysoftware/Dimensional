//
//  LevelPassedScene.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 02.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "LevelPassedScene.h"
#import "SKButton.h"
#import "MainView.h"
#import "LevelScene.h"
#import "GameCenterManager.h"

@implementation LevelPassedScene

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [SKColor clearColor];

    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    NSString *chapterId = self.userInfo[@"chapterId"];
    NSString *levelId = self.userInfo[@"levelId"];
    NSString *leaderboardName = [NSString stringWithFormat:@"leaderboard_%@%@", chapterId, levelId];
    NSInteger levelSilverScore = [self.userInfo[@"silverScore"] integerValue];
    NSInteger levelGoldScore = [self.userInfo[@"goldScore"] integerValue];
    int score = [self.userInfo[@"score"] intValue];
    int highScore = [[GameCenterManager sharedManager] highScoreForLeaderboard:leaderboardName];
    [[GameCenterManager sharedManager] saveAndReportScore:score
                                              leaderboard:leaderboardName
                                                sortOrder:GameCenterSortOrderHighToLow];

    //background node
    SKSpriteNode *backgroundNode = (SKSpriteNode*)[self.scene childNodeWithName:@"Background"];
    SKLabelNode *title = (SKLabelNode*)[backgroundNode childNodeWithName:@"Title"];
    SKLabelNode *scoreStatic = (SKLabelNode*)[backgroundNode childNodeWithName:@"YouScoredLabel"];
    SKLabelNode *scoreLabel = (SKLabelNode*)[backgroundNode childNodeWithName:@"ScoreLabel"];
    SKLabelNode *highScoreLabel = (SKLabelNode*)[backgroundNode childNodeWithName:@"highScoreLabel"];
    SKLabelNode *unlockLabel1 = (SKLabelNode*)[backgroundNode childNodeWithName:@"LevelUnlockText1"];
    SKLabelNode *unlockLabel2 = (SKLabelNode*)[backgroundNode childNodeWithName:@"LevelUnlockText2"];
    SKLabelNode *leaderboardLabel1 = (SKLabelNode*)[backgroundNode childNodeWithName:@"LeaderboardLabel1"];
    SKLabelNode *leaderboardLabel2 = (SKLabelNode*)[backgroundNode childNodeWithName:@"LeaderboardLabel2"];
    SKSpriteNode *star1 = (SKSpriteNode*)[backgroundNode childNodeWithName:@"Star1"];
    SKSpriteNode *star2 = (SKSpriteNode*)[backgroundNode childNodeWithName:@"Star2"];
    SKSpriteNode *star3 = (SKSpriteNode*)[backgroundNode childNodeWithName:@"Star3"];

    SKButton *leaderboardsButton = [[SKButton alloc] initWithTextureNormal:nil selected:nil];
    leaderboardsButton.position = CGPointZero;
    leaderboardsButton.size = CGSizeMake(325, 85);
    leaderboardsButton.zPosition = 2;
    [leaderboardsButton setTouchUpInsideTarget:self action:@selector(showLeaderboards)];
    leaderboardsButton.alpha = 0;
    [leaderboardLabel2 addChild:leaderboardsButton];

    //leaderboards and high score
    if (highScore>score){
        highScoreLabel.text = [NSString stringWithFormat:@"High score: %d", highScore];
    }
    else if (highScore>0){
        highScoreLabel.text = @"New high score!";
    }
    else{
        highScoreLabel.hidden = YES;
    }

    leaderboardLabel1.alpha = 0;
    leaderboardLabel2.alpha = 0;
    BOOL isGameCenterAvailable = [[GameCenterManager sharedManager] checkGameCenterAvailability];
    if (isGameCenterAvailable){
        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
        if (leaderboardRequest != nil){
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderboardRequest.range = NSMakeRange(1, 3);
            leaderboardRequest.identifier = [NSString stringWithFormat:@"leaderboard_%@%@", chapterId, levelId];
            [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                if (error != nil){
                    NSLog(@"Leaderboard Request Error: %@", error.localizedDescription);
                }
                if (scores != nil){
                    if (scores.count==0){ //пустая таблица
                        leaderboardLabel1.text = @"Your friends have never played this level";
                        leaderboardLabel2.text = @"Invite them to the game!";
                        [leaderboardsButton setTouchUpInsideTarget:self action:@selector(inviteFriends)];
                    }
                    else{
                        GKScore *topScore = scores[0];
                        if ([topScore.playerID isEqualToString:[GameCenterManager sharedManager].localPlayerId]){ //я #1
                            if (scores.count==1){//#1 out of 1
                                leaderboardLabel1.text = @"Your friends have never played this level";
                                leaderboardLabel2.text = @"Invite them to the game!";
                                [leaderboardsButton setTouchUpInsideTarget:self action:@selector(inviteFriends)];
                            }
                            else{//real #1
                                if (topScore.value>score){
                                    leaderboardLabel1.text = @"You're still #1 on this level";
                                    leaderboardLabel2.text = @"See the leaderboards";
                                }
                                else{
                                    leaderboardLabel1.text = @"You're beaten your own record!";
                                    leaderboardLabel2.text = @"Great job!";
                                }
                            }
                        }
                        else{
                            if (score>topScore.value){//the new #1
                                leaderboardLabel1.text = [NSString stringWithFormat:@"You beat %@'s score by %lld", topScore.player.alias, score-topScore.value];
                                leaderboardLabel2.text = @"Legendary play!";
                            }
                            else if (score==topScore.value){//#1 == you
                                leaderboardLabel1.text = [NSString stringWithFormat:@"You share #1 with %@", topScore.player.alias];
                                leaderboardLabel2.text = @"Great job!";
                            }
                            else{//you're worse than my grandma
                                leaderboardLabel1.text = [NSString stringWithFormat:@"Your friend %@ scored %lld more than you.", topScore.player.alias, topScore.value-score];
                                leaderboardLabel2.text = @"Try to beat that!";
                            }
                        }
                    }

                    SKAction *fadeIn = [SKAction fadeInWithDuration:1];
                    fadeIn.timingMode = SKActionTimingEaseInEaseOut;
                    [leaderboardLabel1 runAction:fadeIn];
                    [leaderboardLabel2 runAction:fadeIn];
                }
            }];
        }
    }


    //DEFAULTS FOR ANIMATING
    [star1 setScale:0];
    [star2 setScale:0];
    [star3 setScale:0];
    star1.alpha = 0;
    star2.alpha = 0;
    star3.alpha = 0;
    scoreLabel.position = CGPointMake(0, scoreLabel.position.y-25);
    scoreStatic.position = CGPointMake(0, scoreStatic.position.y-25);
    highScoreLabel.position = CGPointMake(0, highScoreLabel.position.y-25);
    highScoreLabel.alpha = 0;
    scoreLabel.alpha = 0;
    scoreStatic.alpha = 0;

    //restart level button
    SKButton *restartButton = [[SKButton alloc] initWithImageNamed:@"restartButton" colorNormal:UI_COLOR_ORANGE_STAY_NORMAL colorSelected:UI_COLOR_ORANGE_STAY_SELECTED];
    [restartButton setPosition:CGPointMake(-346, -200)];
    restartButton.size = CGSizeMake(96, 96);
    restartButton.zPosition = 2;
    [restartButton setTouchUpInsideTarget:self action:@selector(restartLevel)];
    [backgroundNode addChild:restartButton];

    //next button
    BOOL notEnoughStarsToPass = NO;
    if (notEnoughStarsToPass){ //NOT ENOUGH STARS -> BACK TO LEVEL SELECTOR
        SKButton *playButton = [[SKButton alloc] initWithImageNamed:@"notEnoughStars" colorNormal:[SKColor blueColor] colorSelected:[SKColor greenColor]];
        [playButton setPosition:CGPointMake(346, -200)];
        playButton.zPosition = 2;
        playButton.size = CGSizeMake(96, 96);
        [playButton setTouchUpInsideTarget:self action:@selector(toLevelSelector)];
        [backgroundNode addChild:playButton];
    }
    else if ([levelId integerValue] != 9){ //TO NEXT LEVEL
        unlockLabel1.alpha = 0;
        unlockLabel2.alpha = 0;
        SKButton *playButton = [[SKButton alloc] initWithImageNamed:@"playButton" colorNormal:UI_COLOR_GREEN_NEXT_NORMAL colorSelected:UI_COLOR_GREEN_NEXT_SELECTED];
        [playButton setPosition:CGPointMake(346, -200)];
        playButton.zPosition = 2;
        playButton.size = CGSizeMake(96, 96);
        [playButton setTouchUpInsideTarget:self action:@selector(nextLevel)];
        [backgroundNode addChild:playButton];
    }
    else{ // TO NEXT CHAPTER'S LEVEL SELECTOR

    }

    //score label
    float duration = ((float)score/(float)levelGoldScore)*1.5;
    if (duration>2) duration = 2;
    [self animateLabel:scoreLabel fromNumber:0 ToNumber:score andDuration:duration completion:nil];
    SKAction *animateScoreLabel2 = [SKAction group:@[[SKAction fadeInWithDuration:.1], [SKAction moveByX:0 y:25 duration:.3]]];
    [scoreLabel runAction:[SKAction sequence:@[[SKAction waitForDuration:.2], animateScoreLabel2]]];
    [scoreStatic runAction:animateScoreLabel2];
    [highScoreLabel runAction:[SKAction sequence:@[[SKAction waitForDuration:.5], animateScoreLabel2]]];

    //stars
    SKTexture *fullStarTexture = [[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"FullStar"];
    SKAction *animateFullStar = [SKAction group:@[[SKAction fadeInWithDuration:.6], [SKAction scaleTo:1 duration:.6]]];
    animateFullStar.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *animateEmptyStar = [SKAction group:@[[SKAction fadeInWithDuration:.6], [SKAction scaleTo:1 duration:0]]];
    animateEmptyStar.timingMode = SKActionTimingEaseInEaseOut;

    [star1 runAction:[SKAction sequence:@[[SKAction waitForDuration:.3], animateFullStar]]];
    if (score>=levelSilverScore){
        star2.texture = fullStarTexture;
        [star2 runAction:[SKAction sequence:@[[SKAction waitForDuration:.6], animateFullStar]]];
        if (score>=levelGoldScore){
            star3.texture = fullStarTexture;
            [star3 runAction:[SKAction sequence:@[[SKAction waitForDuration:.9], animateFullStar]]];
        }
        else{
            [star3 runAction:[SKAction sequence:@[[SKAction waitForDuration:.9], animateEmptyStar]]];
        }
    }
    else{
        [star2 runAction:[SKAction sequence:@[[SKAction waitForDuration:.6], animateEmptyStar]]];
        [star3 runAction:[SKAction sequence:@[[SKAction waitForDuration:.9], animateEmptyStar]]];
    }
}

-(void)animateLabel:(SKLabelNode*)label fromNumber:(NSInteger)startNumber ToNumber:(NSInteger)endNumber andDuration:(float)fullDuration completion:(void (^)())completion{
    [label removeAllActions];
    NSMutableArray *animationsArray = [[NSMutableArray alloc] init];
    int changesCount = 30*fullDuration;
    float duration = fullDuration/changesCount;
    float formula = endNumber - startNumber;
    for (int i=1; i<=changesCount; i++){
        NSInteger number = roundf(startNumber+formula/changesCount*i);
        SKAction *basicTextChange = [SKAction sequence:@[[SKAction runBlock:^{
            label.text = [NSString stringWithFormat:@"%ld", (long)number];
        }], [SKAction waitForDuration:duration]]];
        [animationsArray addObject:basicTextChange];
    }
    SKAction *fullAnimations = [SKAction sequence:animationsArray];
    [label runAction:fullAnimations completion:completion];
}

-(void)showLeaderboards{
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:((PopoverView*)self.view).superView];
}

-(void)inviteFriends{
    NSLog(@"Inviting friends, yeah...");
}

-(void)toLevelSelector{
    [[NSNotificationCenter defaultCenter] postNotificationName:PopoverView_DismissPopover object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:LevelScene_UnloadLevel object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MainView_SwitchToLevelSelectorSceneNotification object:nil];
}

-(void)restartLevel{
    [[NSNotificationCenter defaultCenter] postNotificationName:PopoverView_DismissPopover object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:LevelScene_RestartLevel object:nil];
}

-(void)nextLevel{
    [[NSNotificationCenter defaultCenter] postNotificationName:PopoverView_DismissPopover object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:LevelScene_UnloadLevel object:nil];
    NSInteger integerLevelId = [self.userInfo[@"levelId"] integerValue];
    integerLevelId++;
    NSString *levelFormat = integerLevelId>=10 ? @"%ld" : @"0%ld";
    NSString *levelId = [NSString stringWithFormat:levelFormat, (long)integerLevelId];
    NSString *chapterId = self.userInfo[@"chapterId"];

    [[NSNotificationCenter defaultCenter] postNotificationName:MainView_SwitchToLevelSceneNotification
                                                        object:nil
                                                      userInfo:@{@"chapterId":chapterId, @"levelId":levelId}];
}
@end
