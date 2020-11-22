//
//  LevelScene.m
//  Geometry
//
//  Created by Ярослав Ерохин on 10.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "LevelScene.h"
#import "SKButton.h"
#import "Player.h"
#import "Enemy.h"
#import "AppDelegate.h"
#import "Projectile.h"
#import "Multiplier.h"
#import "MainView.h"
#import "Projectile.h"
#import "GameCenterManager.h"
#import "JCJoystick.h"
#import "PauseNode.h"
#import "PopoverView.h"
#import "Dimensional-Swift.h"

@interface LevelScene () <SKPhysicsContactDelegate, PauseNodeDelegate, LevelPassedNodeDelegate>
@property (assign, nonatomic) NSInteger score, scoreMultiplier, defencesLeft;
@property (assign, nonatomic) BOOL levelPaused;
@end

@implementation LevelScene {
    //scene life cycle
    AppDelegate *appDelegate;
    float _lastUpdateTime, _dt, joystickRightRotationAngle, currentLevelTime, fireTimerSinceFired;
    NSString *gameState;

    //Audio
    float newVolume;

    //controls
    CGPoint joystickRightPoint, joystickLeftPoint;
    UITouch *joystickLeftTouch, *joystickRightTouch;
    JCJoystick *joystickLeft, *joystickRight;

    //gameplay stuff
    NSMutableArray *enemies, *enemiesToSpawn, *projectiles, *presentMultipliers;
    NSInteger currentLevel, nextSpawnTime, numberOfSpawnsSinceSpecial, enemiesKilled;
    NSArray *levelSettings, *enemyTypes;
    NSDictionary *currentLevelSettings;
    BOOL specialSpawnInProgress, shouldUseController, shouldOfferRewardedVideo;

    //timers
    NSDate *spawnTimerPauseStart, *spawnTimerPreviousFireDate;
    NSTimer *spawnTimer;

    //ui
    SKNode *glassNode;
    SKSpriteNode *borderNode, *defencesLeftIconNode;
    SKButton *pauseButton;
    SKLabelNode *scoreLabelNode, *defencesLeftLabelNode, *multiplierLabelNode;
    Player *player;
    MainView *mainView;
}

@synthesize score = _score, scoreMultiplier = _scoreMultiplier, levelPaused = _levelPaused, defencesLeft = _defencesLeft;

//СЦЕНА ГЕЙМПЛЕЯ
//игрок, противники, джойстики, кнопка паузы, рамка, счет

#pragma mark - Game controller methods

-(void)setupControllers{
    if (appDelegate.currentController){
        [self controllerSetActive:YES];
        [self setUpUIForController];
    }
    else{
        [self controllerSetActive:NO];
    }
    if ([gameState isEqualToString:LevelScene_GameStatus_Playing] && currentLevelTime > 3) {
        [self pause];
    }
}

-(void)setUpUIForController{
    //Pause by controller
    [appDelegate gamepadResetButtonsHandlers];
    __unsafe_unretained typeof(self) weakSelf = self;
    appDelegate.currentController.controllerPausedHandler = ^(GCController *controller) {
        [weakSelf pause];
    };
}

-(void)controllerSetActive:(BOOL)active{
    if (active){
        [pauseButton removeFromParent];
        shouldUseController = YES;
    }
    else{
        if (!pauseButton.parent){ [self.scene addChild:pauseButton]; }
        shouldUseController = NO;
    }
}

#pragma mark - Scene life cycle

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)willResignActive: (NSNotification*) notification {
#ifdef DEBUG
    NSLog(@"levelScene: willResignActive");
#endif
    if (![gameState isEqualToString:LevelScene_GameStatus_Paused] && ![gameState isEqualToString:LevelScene_GameStatus_Over])
        [self pause];
}

-(void)didBecomeActive: (NSNotification*) notification {
#ifdef DEBUG
    NSLog(@"levelScene: didBecomeActive, paused = %@", self.levelPaused ? @"YES" : @"NO");
#endif
}

-(instancetype)initWithSize:(CGSize)size andEdgeInsets:(UIEdgeInsets)safeEdges {
    self = [super initWithSize: size];
    if (self) {
        self.physicsWorld.gravity = CGVectorMake(0, 0);

        appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [GCController stopWirelessControllerDiscovery];

        // ИНИЦИАЛИЗАЦИЯ
        gameState = LevelScene_GameStatus_Initializing;
        enemies = [[NSMutableArray alloc] init];
        enemiesToSpawn = [[NSMutableArray alloc] init];
        projectiles = [[NSMutableArray alloc] init];
        presentMultipliers = [[NSMutableArray alloc] init];

        CGFloat topY = (size.height/2) - safeEdges.top - 5;

        // joystick controls
        joystickRight = [[JCJoystick alloc]
                         initWithControlRadius: 80
                         baseRadius: 80
                         baseColor: [SKColor colorWithRed: 1 green: 1 blue: 1 alpha: .1]
                         joystickRadius: 30
                         joystickColor: [SKColor colorWithRed: 1 green: 1 blue: 1 alpha: .4]];
        [joystickRight setUserInteractionEnabled: NO];
        joystickRight.position = CGPointMake(350, -192);
        joystickRight.zPosition = 2;

        joystickLeft = [[JCJoystick alloc]
                        initWithControlRadius: 80
                        baseRadius: 80
                        baseColor: [SKColor colorWithRed: 1 green: 1 blue: 1 alpha: .1]
                        joystickRadius: 30
                        joystickColor: [SKColor colorWithRed: 1 green: 1 blue: 1 alpha: .4]];
        [joystickLeft setUserInteractionEnabled: NO];
        joystickLeft.position = CGPointMake(-350, -192);
        joystickLeft.zPosition = 2;

        SKTexture *defencesTexture = [[SKTextureAtlas atlasNamed: @"UI"] textureNamed: @"defencesLeftIcon"];
        defencesLeftIconNode = [SKSpriteNode spriteNodeWithTexture:defencesTexture size: CGSizeMake(19, 19)];
        defencesLeftIconNode.anchorPoint = CGPointMake(1, 1);
        CGFloat defencesLeftIconX = (size.width/2 - 19 - 10 - safeEdges.left) * -1;
        CGFloat defencesLeftIconY = topY;
        defencesLeftIconNode.position = CGPointMake(defencesLeftIconX, defencesLeftIconY);
        defencesLeftIconNode.zPosition = 1;

        defencesLeftLabelNode = [[SKLabelNode alloc] initWithFontNamed: @"Teko Light"];
        defencesLeftLabelNode.fontSize = 30;
        defencesLeftLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        defencesLeftLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        CGFloat defencesLeftLabelX = defencesLeftIconNode.position.x + 5;
        CGFloat defencesLeftLabelY = topY;
        defencesLeftLabelNode.position = CGPointMake(defencesLeftLabelX, defencesLeftLabelY);
        defencesLeftLabelNode.text = @"0";
        defencesLeftLabelNode.zPosition = 1;

        multiplierLabelNode = [[SKLabelNode alloc] initWithFontNamed: @"Teko Light"];
        multiplierLabelNode.fontSize = 30;
        multiplierLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        multiplierLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        multiplierLabelNode.position = CGPointMake(0, topY - 2);
        multiplierLabelNode.text = @"x1";
        multiplierLabelNode.zPosition = 1;

        scoreLabelNode = [[SKLabelNode alloc] initWithFontNamed: @"Teko Light"];
        scoreLabelNode.fontSize = 60;
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        scoreLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        CGFloat scoreLabelX = 0;
        CGFloat scoreLabelY = topY - 2;
        scoreLabelNode.position = CGPointMake(scoreLabelX, scoreLabelY);
        scoreLabelNode.text = @"0";
        scoreLabelNode.zPosition = 1;

        pauseButton = [[SKButton alloc] initWithImageNamed: @"pauseButton"
                                               colorNormal: [SKColor whiteColor]
                                             colorSelected: UI_COLOR_RED_BACK_SELECTED];
        CGFloat pauseButtonX = size.width/2 - 22 - safeEdges.right;
        CGFloat pauseButtonY = topY - 30;
        pauseButton.position = CGPointMake(pauseButtonX, pauseButtonY);
        pauseButton.size = CGSizeMake(90, 90);
        [pauseButton setTouchDownTarget: self action: @selector(pause)];
        pauseButton.zPosition = 2;

        // ОСНОВНЫЕ НАСТРОЙКИ
        self.backgroundColor = [SKColor clearColor];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        self.anchorPoint = CGPointMake(0.5, 0.5);

        borderNode = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed: @"border"]];
        borderNode.size = CGSizeMake(1100, 900);
        borderNode.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:
                                  CGRectMake(borderNode.frame.origin.x+4, borderNode.frame.origin.y+4,
                                             borderNode.size.width-8, borderNode.size.height-8)];
        borderNode.physicsBody.categoryBitMask = WallCategoryBitMask;
        borderNode.physicsBody.usesPreciseCollisionDetection = YES;

        glassNode = [SKNode node];
        glassNode.zPosition = 1;

        player = [[Player alloc] initWithPosition: CGPointMake(0, 0)];

        // multitasking
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(willResignActive:)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didBecomeActive:)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(setupControllers)
                                                     name: NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED
                                                   object: nil];

        NSDictionary *level0Settings = @{ @"points":@0, @"spawnTime":@6.5,
                                          @"spawnCount":@5, @"fireTime":@.25,
                                          @"fireCount":@1, @"multiplierCount":@1,
                                          @"rectangleChance":@65, @"iTriangleChance":@20,
                                          @"eTriangleChance":@5, @"pentagonChance":@0 };
        NSDictionary *level1Settings = @{ @"points":@500, @"spawnTime":@5.5,
                                          @"spawnCount":@6, @"fireTime":@.23,
                                          @"fireCount":@1, @"multiplierCount":@3,
                                          @"rectangleChance":@56, @"iTriangleChance":@30,
                                          @"eTriangleChance":@10, @"pentagonChance":@5 };
        NSDictionary *level2Settings = @{ @"points":@5000, @"spawnTime":@5.0,
                                          @"spawnCount":@7, @"fireTime":@.25,
                                          @"fireCount":@2, @"multiplierCount":@5,
                                          @"rectangleChance":@40, @"iTriangleChance":@20,
                                          @"eTriangleChance":@15, @"pentagonChance":@5 };
        NSDictionary *level3Settings = @{ @"points":@35000, @"spawnTime":@5.25,
                                          @"spawnCount":@8, @"fireTime":@.23,
                                          @"fireCount":@2, @"multiplierCount":@7,
                                          @"rectangleChance":@20, @"iTriangleChance":@20,
                                          @"eTriangleChance":@20, @"pentagonChance":@20 };
        NSDictionary *level4Settings = @{ @"points":@100000, @"spawnTime":@5.0,
                                          @"spawnCount":@9, @"fireTime":@.21,
                                          @"fireCount":@2, @"multiplierCount":@9,
                                          @"rectangleChance":@20, @"iTriangleChance":@20,
                                          @"eTriangleChance":@20, @"pentagonChance":@20 };
        NSDictionary *level5Settings = @{ @"points":@250000, @"spawnTime":@4.5,
                                          @"spawnCount":@10, @"fireTime":@.19,
                                          @"fireCount":@2, @"multiplierCount":@11,
                                          @"rectangleChance":@20, @"iTriangleChance":@20,
                                          @"eTriangleChance":@20, @"pentagonChance":@20 };
        NSDictionary *level6Settings = @{ @"points":@750000, @"spawnTime":@4.5,
                                          @"spawnCount":@9, @"fireTime":@.21,
                                          @"fireCount":@3, @"multiplierCount":@13,
                                          @"rectangleChance":@20, @"iTriangleChance":@20,
                                          @"eTriangleChance":@20, @"pentagonChance":@20 };
        NSDictionary *level7Settings = @{ @"points":@1500000, @"spawnTime":@4.25,
                                          @"spawnCount":@10, @"fireTime":@.19,
                                          @"fireCount":@3, @"multiplierCount":@15,
                                          @"rectangleChance":@20, @"iTriangleChance":@20,
                                          @"eTriangleChance":@20, @"pentagonChance":@20 };
        NSDictionary *level8Settings = @{ @"points":@2500000, @"spawnTime":@4.0,
                                          @"spawnCount":@11, @"fireTime":@.17,
                                          @"fireCount":@3, @"multiplierCount":@17,
                                          @"rectangleChance":@20, @"iTriangleChance":@20,
                                          @"eTriangleChance":@20, @"pentagonChance":@20 };
        NSDictionary *level9Settings = @{ @"points":@3500000, @"spawnTime":@3.75,
                                          @"spawnCount":@12, @"fireTime":@.15,
                                          @"fireCount":@3, @"multiplierCount":@19,
                                          @"rectangleChance":@20, @"iTriangleChance":@20,
                                          @"eTriangleChance":@20, @"pentagonChance":@20 };
        NSDictionary *level10Settings = @{ @"points":@5000000, @"spawnTime":@3.5,
                                           @"spawnCount":@12, @"fireTime":@.17,
                                           @"fireCount":@4, @"multiplierCount":@21,
                                           @"rectangleChance":@20, @"iTriangleChance":@20,
                                           @"eTriangleChance":@20, @"pentagonChance":@20 };

        levelSettings = @[level0Settings, level1Settings, level2Settings,
                          level3Settings, level4Settings, level5Settings, level6Settings,
                          level7Settings, level8Settings, level9Settings, level10Settings];
        enemyTypes = @[ENEMY_TYPE_RECTANGLE, ENEMY_TYPE_RHOMB, ENEMY_TYPE_ETRIANGLE,
                       ENEMY_TYPE_PENTAGON, ENEMY_TYPE_ITRIANGLE];

    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    mainView = (MainView*)self.view;
    mainView.multipleTouchEnabled = YES;

    [self.scene addChild: defencesLeftLabelNode];
    [self.scene addChild: scoreLabelNode];
    [self.scene addChild: multiplierLabelNode];
    [self.scene addChild: pauseButton];
    [self.scene addChild: glassNode];
    [self.scene addChild: defencesLeftIconNode];
    [glassNode addChild: borderNode];

    //hide ui
    defencesLeftLabelNode.alpha = 0;
    scoreLabelNode.alpha = 0;
    multiplierLabelNode.alpha = 0;
    pauseButton.alpha = 0;
    defencesLeftIconNode.alpha = 0;

    //СТАНДАРТНЫЕ ЗНАЧЕНИЯ
    glassNode.alpha = 1;
    self.scoreMultiplier = 1;
    currentLevelTime = 0;
    self.score = 0;

    [self setupControllers];
    [self loadLevel];

    //player animation
    player.xScale = 0;
    player.yScale = 0;
    player.alpha = 0;
    [glassNode addChild:player];
    [player runAction:[SKAction scaleTo: 1 duration: .25]];
    [player runAction:[SKAction fadeInWithDuration: .25]];
}

-(void)update:(CFTimeInterval)currentTime {
    _dt = _lastUpdateTime ? currentTime - _lastUpdateTime : 0;
    _lastUpdateTime = currentTime;

    if (!self.levelPaused){
        //controller
        if (shouldUseController){
            if (appDelegate.currentController.extendedGamepad){
                joystickLeftPoint = CGPointMake(appDelegate.currentController.extendedGamepad.leftThumbstick.xAxis.value,
                                                appDelegate.currentController.extendedGamepad.leftThumbstick.yAxis.value);
                joystickRightPoint = CGPointMake(appDelegate.currentController.extendedGamepad.rightThumbstick.xAxis.value,
                                                 appDelegate.currentController.extendedGamepad.rightThumbstick.yAxis.value);
            }
            else{
                [self controllerSetActive:NO];
            }
        }
        if ((joystickLeft.x != 0 && joystickLeft.y != 0) || !shouldUseController){
            joystickLeftPoint = CGPointMake(joystickLeft.x, joystickLeft.y);
        }
        if ((joystickRight.x != 0 && joystickRight.y != 0) || !shouldUseController){
            joystickRightPoint = CGPointMake(joystickRight.x, joystickRight.y);
        }

        //movements
        for (Projectile *s in projectiles) {
            [s moveWithDeltaTime:_dt andBorderNode:borderNode.frame];
        }

        fireTimerSinceFired+=_dt;
        if (fireTimerSinceFired > [levelSettings[currentLevel][@"fireTime"] doubleValue]){
            [self playerFire];
        }

        if (joystickLeftPoint.x != 0 || joystickLeftPoint.y != 0){
            [player moveWithDirection:joystickLeftPoint deltaTime:_dt andBorderNode:borderNode.frame];
            [self moveGlassWithTime:0];
        }

        for (Enemy *s in enemies) {
            [s moveWithDeltaTime:_dt borderNode:borderNode.frame playerPosition:player.position andProjectiles:projectiles];
        }
    }
}

#pragma mark - Gameplay life cycle

-(void)loadLevel{
	[[SoundManager shared] playGameMusic];

    joystickLeft.userInteractionEnabled = YES;
    joystickRight.userInteractionEnabled = YES;
    gameState = LevelScene_GameStatus_Playing;
    currentLevelTime = 0;
    nextSpawnTime = 0;
    self.defencesLeft = Defences_Left; //lives to go
    numberOfSpawnsSinceSpecial = 0;
    spawnTimer = [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(spawnTimerTick) userInfo:nil repeats:YES];
    currentLevel = -1;
    [self setCurrentLevel:0];

    //show ui
    defencesLeftLabelNode.alpha = 1;
    defencesLeftIconNode.alpha = 1;
    multiplierLabelNode.text = @"x1";
    multiplierLabelNode.alpha = 1;
    scoreLabelNode.text = @"0";
    scoreLabelNode.alpha = 1;
    pauseButton.alpha = 1;
}

-(void)restartLevel{
    gameState = LevelScene_GameStatus_Initializing;
    [self updateEnemiesKilledCounter];

    [self resume];
    [spawnTimer invalidate];
    for (SKNode *s in glassNode.children) {
        if (![s isEqual:borderNode] && ![s isEqual:player]){
            [s removeFromParent];
        }
    }
    [player runAction:[SKAction scaleTo:1 duration:0]];
    player.alpha = 1;
    player.position = CGPointZero;
    [self moveGlassWithTime:.25];

    enemies = [[NSMutableArray alloc] init];
    enemiesToSpawn = [[NSMutableArray alloc] init];
    projectiles = [[NSMutableArray alloc] init];
    presentMultipliers = [[NSMutableArray alloc] init];

    //СТАНДАРТНЫЕ ЗНАЧЕНИЯ
    glassNode.alpha = 1;
    self.scoreMultiplier = 1;
    self.score = 0;
    [self loadLevel];
}

-(void)setLevelPaused:(BOOL)levelPaused{
    _levelPaused = levelPaused;

    if (levelPaused){
        for (Multiplier *s in presentMultipliers){
            s.speed = 0;
            s.physicsBody.dynamic = NO;
        }
    }
    else{
        for (Multiplier *s in presentMultipliers){
            s.speed = 1;
            s.physicsBody.dynamic = YES;
        }
    }
}

-(void)pause{
#ifdef DEBUG
    NSLog(@"levelScene: pause");
#endif
    if (![self.scene childNodeWithName:@"PauseNode"] &&
        ![gameState isEqualToString:LevelScene_GameStatus_Paused] &&
        ![gameState isEqualToString:LevelScene_GameStatus_Over]){

        [mainView presentPauseMenuWithDelegate:self];
        joystickLeft.userInteractionEnabled = NO;
        joystickRight.userInteractionEnabled = NO;
        gameState = LevelScene_GameStatus_Paused;
        self.levelPaused = YES;
        [self pauseTimer:spawnTimer];
    }
}

-(void)resume{
#ifdef DEBUG
    NSLog(@"levelScene: resume");
#endif

    joystickLeft.userInteractionEnabled = YES;
    joystickRight.userInteractionEnabled = YES;
    gameState = LevelScene_GameStatus_Playing;
    self.levelPaused = NO;
    [self resumeTimer:spawnTimer];
}

-(void)gameOver{
    if (![gameState isEqualToString:LevelScene_GameStatus_Over]){
        gameState = LevelScene_GameStatus_Over;
#ifdef DEBUG
        NSLog(@"levelScene: gameOver (time: %f, score: %ld x%ld)", currentLevelTime, (long)_score, (long)_scoreMultiplier);
#endif

        joystickLeft.userInteractionEnabled = NO;
        joystickRight.userInteractionEnabled = NO;
        self.levelPaused = YES;
        [spawnTimer invalidate];
        [scoreLabelNode removeAllActions];

        //hide ui
        defencesLeftLabelNode.alpha = 0;
        defencesLeftIconNode.alpha = 0;
        scoreLabelNode.alpha = 0;
        multiplierLabelNode.alpha = 0;
        pauseButton.alpha = 0;
        glassNode.alpha = 0;

        //update game times for ads
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setFloat:currentLevelTime forKey:USERDEFAULTS_LASTGAMETIME];
        float _longestGame = [settings floatForKey:USERDEFAULTS_LONGESTGAMETIME];
#ifdef DEBUG
        NSLog(@"levelScene: longest game on this install: %f seconds. This game went for %f", _longestGame, currentLevelTime);
#endif
        if (_longestGame < currentLevelTime)
            [settings setFloat:currentLevelTime forKey:USERDEFAULTS_LONGESTGAMETIME];

        [self updateEnemiesKilledCounter];
        [mainView presentLevelPassedNodeWithScore:_score andDelegate:self];
    }
}

-(void)unloadLevel{
#ifdef DEBUG
    NSLog(@"levelScene: unloadLevel");
#endif

    self.levelPaused = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SKAction *action = [SKAction moveTo:CGPointZero duration:.25];
    action.timingMode = UIViewAnimationCurveEaseInOut;
    [self.backgroundNode runAction:action];
    //timers turn off
    [spawnTimer invalidate];
    spawnTimer = nil;
}

#pragma mark - Game methods

-(void)playerFire {
    if (joystickRightPoint.x != 0 || joystickRightPoint.y != 0){
        fireTimerSinceFired = 0;
//        float flightAngle = DEGREES_TO_RADIANS(CGPointToDegree(CGPointMake(joystickRightPoint.x, joystickRightPoint.y)));
        float flightAngle = DEGREES_TO_RADIANS(CGPointToDegree(CGPointMake(joystickRightPoint.x, joystickRightPoint.y)));

        player.zRotation = flightAngle;
        NSInteger count = [levelSettings[currentLevel][@"fireCount"] integerValue];
        for (int i=0; i<count; i++){
            int distance = 9;
            float startPoint = distance*(count-1)/2;
            float thisPoint = startPoint - distance*i;
            CGPoint position = pointAroundCircumferenceFromCenter(player.position, thisPoint, flightAngle-90);
            Projectile *projectile = [[Projectile alloc] initWithPosition:position andAngle:flightAngle];
            projectile.containingArray = projectiles;
            [glassNode addChild:projectile];
            [projectiles addObject:projectile];

            //PlayEffect(@"playerShot.wav");
        }
    }
}

-(void)spawnTimerTick {
    //Score progress: change Level
    if (self.score < [levelSettings[0][@"points"] intValue]) { [self setCurrentLevel:0]; }
    else if (self.score >= [levelSettings[10][@"points"] intValue]) { [self setCurrentLevel:10]; }
    else if (self.score >= [levelSettings[9][@"points"] intValue]) { [self setCurrentLevel:9]; }
    else if (self.score >= [levelSettings[8][@"points"] intValue]) { [self setCurrentLevel:8]; }
    else if (self.score >= [levelSettings[7][@"points"] intValue]) { [self setCurrentLevel:7]; }
    else if (self.score >= [levelSettings[6][@"points"] intValue]) { [self setCurrentLevel:6]; }
    else if (self.score >= [levelSettings[5][@"points"] intValue]) { [self setCurrentLevel:5]; }
    else if (self.score >= [levelSettings[4][@"points"] intValue]) { [self setCurrentLevel:4]; }
    else if (self.score >= [levelSettings[3][@"points"] intValue]) { [self setCurrentLevel:3]; }
    else if (self.score >= [levelSettings[2][@"points"] intValue]) { [self setCurrentLevel:2]; }
    else if (self.score >= [levelSettings[1][@"points"] intValue]) { [self setCurrentLevel:1]; }

    int levelSpawnCount = [levelSettings[currentLevel][@"spawnCount"] intValue];
    double levelSpawnTime = [levelSettings[currentLevel][@"spawnTime"] doubleValue];

    //Create next spawn
    if (currentLevelTime == nextSpawnTime){
        specialSpawnInProgress = YES;
        //SPECIAL SPAWN
        if (numberOfSpawnsSinceSpecial > 3 && currentLevel > 0){
            numberOfSpawnsSinceSpecial = 0;
            int randomNumberForSpawnType = arc4random() % 3; //30% chance of special spawn type

            //CORNER SPAWN
            if (randomNumberForSpawnType == 0){
                NSString *enemyType = ENEMY_TYPE_ETRIANGLE;
                int thisSpawnCount = levelSpawnCount;
                float spawnX = borderNode.size.width/2-player.size.width*1.5, spawnY = borderNode.size.height/2 - player.size.height*1.5;

                for (int i=0; i<thisSpawnCount; i++){
                    Enemy *enemy1 = [[Enemy alloc] initWithType:enemyType position:CGPointMake(spawnX, spawnY) isPositionAbsolute:YES
                                                   angleDegrees:0 orIsFacingPlayer:YES alsoPassPlayerPosition:player.position spawnTime:(float)currentLevelTime+(float)i*.5];
                    Enemy *enemy2 = [[Enemy alloc] initWithType:enemyType position:CGPointMake(-spawnX, spawnY) isPositionAbsolute:YES
                                                   angleDegrees:0 orIsFacingPlayer:YES alsoPassPlayerPosition:player.position spawnTime:(float)currentLevelTime+(float)i*.5];
                    Enemy *enemy3 = [[Enemy alloc] initWithType:enemyType position:CGPointMake(-spawnX, -spawnY) isPositionAbsolute:YES
                                                   angleDegrees:0 orIsFacingPlayer:YES alsoPassPlayerPosition:player.position spawnTime:(float)currentLevelTime+(float)i*.5];
                    Enemy *enemy4 = [[Enemy alloc] initWithType:enemyType position:CGPointMake(spawnX, -spawnY) isPositionAbsolute:YES
                                                   angleDegrees:0 orIsFacingPlayer:YES alsoPassPlayerPosition:player.position spawnTime:(float)currentLevelTime+(float)i*.5];
                    [enemiesToSpawn addObjectsFromArray:@[enemy1, enemy2, enemy3, enemy4]];
                }
                nextSpawnTime = currentLevelTime + thisSpawnCount*.75;

                //PlayEffect(@"cornerSpawnBuzz.wav");
            }
            //SPAWN AROUND
            else if (randomNumberForSpawnType == 1){
                int randomNumberForEnemyType = arc4random() % 3;
                NSString *enemyType = ENEMY_TYPE_ETRIANGLE;
                if (randomNumberForEnemyType == 1){ enemyType = ENEMY_TYPE_ITRIANGLE; }
                else if (randomNumberForEnemyType == 2){ enemyType = ENEMY_TYPE_RHOMB; }
                else { enemyType = ENEMY_TYPE_ETRIANGLE; }

                int thisSpawnCount = levelSpawnCount*1.5;
                for (int i=0; i<thisSpawnCount; i++){
                    float angle = i*(360/thisSpawnCount);
                    CGPoint position = pointAroundCircumferenceFromCenter(CGPointZero, player.size.width*7, DEGREES_TO_RADIANS(angle));
                    Enemy *enemy = [[Enemy alloc] initWithType:enemyType position:position isPositionAbsolute:NO angleDegrees:0 orIsFacingPlayer:YES alsoPassPlayerPosition:player.position spawnTime:currentLevelTime];
                    [enemiesToSpawn addObject:enemy];
                }
                nextSpawnTime = currentLevelTime+levelSpawnTime*2;

                //PlayEffect(@"spawnAroundBuzz.wav");
            }
            //LINE SPAWN
            else{
                int randomNumberForEnemyType = arc4random() % 3;
                NSString *enemyType = ENEMY_TYPE_ETRIANGLE;
                if (randomNumberForEnemyType == 0){ enemyType = ENEMY_TYPE_ITRIANGLE; }
                else if (randomNumberForEnemyType == 1){ enemyType = ENEMY_TYPE_ETRIANGLE; }
                else { enemyType = ENEMY_TYPE_RECTANGLE; }

                int randomNumberForDirection = arc4random() % 2; //0=VERTICAL, 1=HORIZONTAL
                int randomNumberForPosition = arc4random() % 2; //0=LEFT/TOP, 1=RIGHT/BOTTOM

                int thisSpawnCount = levelSpawnCount*1.4;
                float spawnX = borderNode.size.width/2-player.size.width*1.2, spawnY = borderNode.size.height/2 - player.size.height*1.2;

                for (int i=0; i<thisSpawnCount; i++){
                    float angle; CGPoint position;
                    if (randomNumberForDirection == 0){//vertical
                        if (randomNumberForPosition == 0){//top
                            angle = -90;
                            position = CGPointMake(-spawnX+i*50, spawnY);
                        }
                        else{//bottom
                            angle = 90;
                            position = CGPointMake(spawnX-i*50, -spawnY);
                        }
                    }
                    else{//horizontal
                        if (randomNumberForPosition == 0){//left
                            angle = 0;
                            position = CGPointMake(-spawnX, -spawnY+i*50);
                        }
                        else{//right
                            angle = 180;
                            position = CGPointMake(spawnX, spawnY-i*50);
                        }
                    }
                    Enemy *enemy = [[Enemy alloc] initWithType:enemyType position:position isPositionAbsolute:YES angleDegrees:angle orIsFacingPlayer:NO alsoPassPlayerPosition:player.position spawnTime:currentLevelTime];
                    [enemiesToSpawn addObject:enemy];
                }
                nextSpawnTime = currentLevelTime + levelSpawnTime;
            }
        }
        else{
            specialSpawnInProgress = NO;
            numberOfSpawnsSinceSpecial++;
            int thisSpawnCount = levelSpawnCount;
            for (int i=0; i<thisSpawnCount; i++){
                //Enemy type selection
                NSString *enemyType;
                int chance = arc4random()%101;
                int rectangleChance = 100 - [levelSettings[currentLevel][@"rectangleChance"] intValue];
                int iTriangleChance = rectangleChance - [levelSettings[currentLevel][@"iTriangleChance"] intValue];
                int eTriangleChance = iTriangleChance - [levelSettings[currentLevel][@"eTriangleChance"] intValue];
                int pentagonChance = eTriangleChance - [levelSettings[currentLevel][@"pentagonChance"] intValue];

                if (chance>=rectangleChance) {enemyType = ENEMY_TYPE_RECTANGLE;}
                else if (chance>=iTriangleChance) {enemyType = ENEMY_TYPE_ITRIANGLE;}
                else if (chance>=eTriangleChance) {enemyType = ENEMY_TYPE_ETRIANGLE;}
                else if (chance>=pentagonChance) {enemyType = ENEMY_TYPE_PENTAGON;}
                else { enemyType = ENEMY_TYPE_RHOMB;}

                int spawnZoneX = borderNode.size.width-player.size.width*3, spawnZoneY = borderNode.size.height-player.size.height*3;
                CGPoint enemyPosition = CGPointMake((arc4random()%spawnZoneX)-(float)(spawnZoneX/2), (arc4random()%spawnZoneY)-(float)(spawnZoneY/2));

                //don't spawn inside player
                float distance = player.size.width*9;
                CGRect playerRect = CGRectMake(player.position.x-distance, player.position.y-distance, distance*2, distance*2);
                if (CGRectContainsPoint(playerRect, enemyPosition)){
                    CGPoint vectorPoint = CGPointMake(enemyPosition.x - player.position.x, enemyPosition.y - player.position.y);
                    float angle = CGPointToDegree(vectorPoint);
                    enemyPosition = pointAroundCircumferenceFromCenter(player.position, distance, DEGREES_TO_RADIANS(angle));
                }

                int enemyAngleRandom = arc4random()%4;
                float enemyRotation = -90.f + (90*enemyAngleRandom);
                BOOL enemyFacingPlayer = [enemyType isEqualToString:ENEMY_TYPE_ETRIANGLE] || [enemyType isEqualToString:ENEMY_TYPE_PENTAGON] ? YES : NO;

                nextSpawnTime = currentLevelTime + levelSpawnTime;
                NSInteger enemySpawnTime = currentLevelTime;

                Enemy *enemy = [[Enemy alloc] initWithType:enemyType
                                                  position:enemyPosition
                                        isPositionAbsolute:YES
                                              angleDegrees:enemyRotation
                                          orIsFacingPlayer:enemyFacingPlayer
                                    alsoPassPlayerPosition:player.position
                                                 spawnTime:enemySpawnTime];
                [enemiesToSpawn addObject:enemy];
            }
        }
    }
    else{ //not time to spawn
        if (enemies.count==0)
            nextSpawnTime = currentLevelTime + .25;
    }

    //Actual Spawn
    NSMutableArray *tempToRemoveFromEnemiesToSpawnArray = [[NSMutableArray alloc] init];
    for (Enemy *s in enemiesToSpawn){
        if (s.spawnTime <= currentLevelTime){
            s.moving = NO;
            s.contactVisible = NO;
            [self spawnEnemy:s];
            [tempToRemoveFromEnemiesToSpawnArray addObject:s];
        }
    }
    for (id s in tempToRemoveFromEnemiesToSpawnArray) {
        [enemiesToSpawn removeObject:s];
    }
    for (Enemy *s in enemies){
        //start moving
        if (s.spawnTime+1 <= currentLevelTime && (!s.moving || !s.contactVisible)){
            s.moving = YES;
            s.contactVisible = YES;
        }
    }
    currentLevelTime+=.25;
}

-(void)spawnEnemy:(Enemy*)e{
    if (!e.isPositionAbsolute){
        e.position = addPoints(player.position, e.position);
    }
    if (e.isFacingPlayer){
        e.zRotation = atan2f(player.position.y - e.position.y, player.position.x - e.position.x);
    }

    [glassNode addChild:e];
    [e correctPosition:borderNode.frame];
    [enemies addObject:e];
    [e refreshPhysicsBodyAndSetPosition:e.position];
    if (![e.type isEqualToString:ENEMY_TYPE_SPENTAGON]){
        [e animateIn];
    }
}

-(void)popupWithString:(NSString*)string ofFontSize:(float)fontSize andColor:(SKColor*)color atPosition:(CGPoint)point {
    SKLabelNode *scoreLabelPopupNode = [[SKLabelNode alloc] initWithFontNamed:appDelegate.defaultFontName];
    scoreLabelPopupNode.fontSize = fontSize;
    scoreLabelPopupNode.fontColor = color;
    scoreLabelPopupNode.text = string;
    scoreLabelPopupNode.position = point;
    [glassNode addChild:scoreLabelPopupNode];
    [scoreLabelPopupNode runAction:[SKAction group:@[[SKAction moveByX:0 y:50 duration:.3],
                                                     [SKAction sequence:@[[SKAction fadeInWithDuration:.2],
                                                                          [SKAction waitForDuration:.25],
                                                                          [SKAction fadeOutWithDuration:.1],
                                                                          [SKAction runBlock:^{[scoreLabelPopupNode removeFromParent];}]]]]]];
}

-(void)moveGlassWithTime:(float)time{
    float distanceX = borderNode.size.width/2.75, distanceY = borderNode.size.height/2.75;
    float xMovement = -player.position.x/1.5, yMovement = -player.position.y/1.5;

    if (xMovement > distanceX){
        xMovement = distanceX;
    }
    else if (xMovement < -distanceX){
        xMovement = -distanceX;
    }
    if (yMovement > distanceY){
        yMovement = distanceY;
    }
    else if (yMovement < -distanceY){
        yMovement = -distanceY;
    }
    [glassNode runAction:[SKAction moveTo:CGPointMake(xMovement, yMovement) duration:time]];
    [self.backgroundNode runAction:[SKAction moveTo:CGPointMake(xMovement/3, yMovement/3) duration:time]];
}

#pragma mark - Game Timers

-(void)pauseTimer:(NSTimer *)timer {
    if ([timer isEqual:spawnTimer]){
        spawnTimerPauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
        spawnTimerPreviousFireDate = [timer fireDate];
        [timer setFireDate:[NSDate distantFuture]];
    }
}

-(void)resumeTimer:(NSTimer *)timer {
    if ([timer isEqual:spawnTimer]){
        float pauseTime = -1*[spawnTimerPauseStart timeIntervalSinceNow];
        [timer setFireDate:[spawnTimerPreviousFireDate initWithTimeInterval:pauseTime sinceDate:spawnTimerPreviousFireDate]];
    }
}

#pragma mark - Audio Controls

#pragma mark - Progress Methods

-(void)updateEnemiesKilledCounter{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSInteger _enemiesKilled = [settings integerForKey:USERDEFAULTS_ENEMIES_KILLED_TOTAL];
#ifdef DEBUG
    NSLog(@"levelScene: %ld enemies killed after last achievement update", (long)_enemiesKilled);
#endif
    [settings setInteger:_enemiesKilled+enemiesKilled forKey:USERDEFAULTS_ENEMIES_KILLED_TOTAL];
    enemiesKilled = 0;

    [settings synchronize];
}

-(void)setScoreMultiplier:(NSInteger)scoreMultiplier{
    //add lives when n multipliers reached
    NSArray *values = @[@100, @500, @1000, @1500, @2000, @3000, @4000, @5000, @6000, @7000, @8000, @9000];
    for (int i=0; i<values.count; i++){
        NSInteger value = [values[i] integerValue];
        if (scoreMultiplier >= value  && _scoreMultiplier < value){
            self.defencesLeft++;
            [self popupWithString:NSLocalizedString(@"popup_life", nil) ofFontSize:appDelegate.mediumFontSize andColor:[UIColor whiteColor] atPosition:player.position];
            break;
        }
    }

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@","];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];

    [multiplierLabelNode animateTextWithFormat:@"x%d" usingNumbersFrom:_scoreMultiplier To:scoreMultiplier withDuration:.1 usingNumberFormatter:formatter andCompletionBlock:nil];
    _scoreMultiplier = scoreMultiplier;
}

-(void)setDefencesLeft:(NSInteger)defencesLeft{
    defencesLeftLabelNode.text = [NSString stringWithFormat:@"%ld", (long)defencesLeft];
    _defencesLeft = defencesLeft;
}

-(void)setCurrentLevel:(NSInteger)level{
    if (currentLevel != level){
#ifdef DEBUG
        NSLog(@"levelScene: level: %ld @ time: %ld", (long)level, (long)currentLevelTime);
#endif
        if (currentLevel > 0) {
            [self popupWithString:NSLocalizedString(@"popup_newlevel", nil) ofFontSize:appDelegate.mediumFontSize andColor:[UIColor whiteColor] atPosition:player.position];
        }
        currentLevel = level;
        currentLevelSettings = levelSettings[level];
        [self.backgroundNode switchColorsForLevel:level];

        //PlayEffect(@"default.wav");
    }
}

#pragma mark - Contact Delegate

-(void)didBeginContact:(SKPhysicsContact *)contact{
    //Enemy - Wall
    if ((contact.bodyA.categoryBitMask == EnemyCategoryBitMask && contact.bodyB.categoryBitMask == WallCategoryBitMask) ||
        (contact.bodyA.categoryBitMask == WallCategoryBitMask && contact.bodyB.categoryBitMask == EnemyCategoryBitMask)){
        Enemy *enemyContactNode = nil;

        if (contact.bodyA.categoryBitMask == EnemyCategoryBitMask){
            enemyContactNode = (Enemy*)contact.bodyA.node;
        }
        else{
            enemyContactNode = (Enemy*)contact.bodyB.node;
        }

        if (enemyContactNode.isContactVisible){
            [enemyContactNode didHitWall];
        }
    }
    //Enemy - Projectile
    else if ((contact.bodyA.categoryBitMask == EnemyCategoryBitMask && contact.bodyB.categoryBitMask == ProjectileCategoryBitMask) ||
             (contact.bodyA.categoryBitMask == ProjectileCategoryBitMask && contact.bodyB.categoryBitMask == EnemyCategoryBitMask)){
        Enemy *enemyContactNode = nil;
        Projectile *projectileContactNode = nil;

        if (contact.bodyA.categoryBitMask == EnemyCategoryBitMask){
            enemyContactNode = (Enemy*)contact.bodyA.node;
            projectileContactNode = (Projectile*)contact.bodyB.node;
        }
        else{
            enemyContactNode = (Enemy*)contact.bodyB.node;
            projectileContactNode = (Projectile*)contact.bodyA.node;
        }

        if (enemyContactNode.isprojectileContactVisible){
            if ([enemyContactNode.type isEqualToString:ENEMY_TYPE_PENTAGON]){
                Enemy *smallPentagon1, *smallPentagon2, *smallPentagon3;

                smallPentagon1 = [[Enemy alloc] initWithType:ENEMY_TYPE_SPENTAGON
                                                    position:addPoints(enemyContactNode.position, CGPointMake(-20, 20))
                                          isPositionAbsolute:YES
                                                angleDegrees:0
                                            orIsFacingPlayer:YES
                                      alsoPassPlayerPosition:player.position
                                                   spawnTime:currentLevelTime-.75];
                smallPentagon1.moving = NO;
                smallPentagon1.contactVisible = NO;

                smallPentagon2 = [[Enemy alloc] initWithType:ENEMY_TYPE_SPENTAGON
                                                    position:addPoints(enemyContactNode.position, CGPointMake(-20, -20))
                                          isPositionAbsolute:YES
                                                angleDegrees:0
                                            orIsFacingPlayer:YES
                                      alsoPassPlayerPosition:player.position
                                                   spawnTime:currentLevelTime-.75];
                smallPentagon2.moving = NO;
                smallPentagon2.contactVisible = NO;

                smallPentagon3 = [[Enemy alloc] initWithType:ENEMY_TYPE_SPENTAGON
                                                    position:addPoints(enemyContactNode.position, CGPointMake(20, 20))
                                          isPositionAbsolute:YES
                                                angleDegrees:0
                                            orIsFacingPlayer:YES
                                      alsoPassPlayerPosition:player.position
                                                   spawnTime:currentLevelTime-.75];
                smallPentagon3.moving = NO;
                smallPentagon3.contactVisible = NO;

                [self spawnEnemy:smallPentagon1];
                [self spawnEnemy:smallPentagon2];
                [self spawnEnemy:smallPentagon3];
            }

            Multiplier *multiplier = [enemyContactNode didHitProjectile];
            if (multiplier){
                [presentMultipliers addObject:multiplier];
                multiplier.containingArray = presentMultipliers;
            }

            [projectileContactNode die];
            [projectiles removeObject:projectileContactNode];
            [enemies removeObject:enemyContactNode];

            //PlayEffect(@"explosion15.wav");

            //score pop up
            [self popupWithString:[NSString stringWithFormat:@"+%ld", (long)1*_scoreMultiplier]
                       ofFontSize:appDelegate.defaultFontSize
                         andColor:enemyContactNode.color
                       atPosition:enemyContactNode.position];

            NSInteger previousScore = self.score;
            self.score += 1*_scoreMultiplier;
            enemiesKilled++;

            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:3];
            [formatter setUsesGroupingSeparator:YES];
            [scoreLabelNode animateTextWithFormat:nil usingNumbersFrom:previousScore To:self.score withDuration:.25 usingNumberFormatter:formatter andCompletionBlock:nil];
        }
    }
    //Enemy - Player
    else if ((contact.bodyA.categoryBitMask == EnemyCategoryBitMask && contact.bodyB.categoryBitMask == PlayerCategoryBitMask) ||
             (contact.bodyA.categoryBitMask == PlayerCategoryBitMask && contact.bodyB.categoryBitMask == EnemyCategoryBitMask)){

        Enemy *enemyContactNode = nil;
        Player *playerContactNode = nil;

        if (contact.bodyA.categoryBitMask == PlayerCategoryBitMask){
            enemyContactNode = (Enemy*)contact.bodyB.node;
            playerContactNode = (Player*)contact.bodyA.node;
        }
        else{
            enemyContactNode = (Enemy*)contact.bodyA.node;
            playerContactNode = (Player*)contact.bodyB.node;
        }

        if (enemyContactNode.isContactVisible) {

            if (self.defencesLeft>0) {
				[[SoundManager shared] hitEnemy];

                self.defencesLeft--;
                [playerContactNode killAllEnemies];

                for (Enemy *s in enemies){
                    [s didHitProjectile];
                }
                enemies = [[NSMutableArray alloc] init];

                if (!specialSpawnInProgress)
                    nextSpawnTime = currentLevelTime + 1.5;

                //PlayEffect(@"playerRespawn.wav");
            }
            else{
				[[SoundManager shared] died];

                self.levelPaused = YES;
                [self pauseTimer:spawnTimer];
                for (Enemy *s in enemies){
                    s.moving = NO;
                }

                [playerContactNode dieWithEnemy:enemyContactNode andCompletionHandler:^{
                    for (Enemy *s in self->enemies){
                        [s didHitProjectile];
                    }
                    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:.4], [SKAction runBlock:^{
                        [self gameOver];
                    }]]]];
                }];
            }
        }
    }
    //Player - Multiplier
    else if ((contact.bodyA.categoryBitMask == MultiplierCategoryBitMask && contact.bodyB.categoryBitMask == PlayerCategoryBitMask) ||
             (contact.bodyA.categoryBitMask == PlayerCategoryBitMask && contact.bodyB.categoryBitMask == MultiplierCategoryBitMask)){
        Multiplier *multiplierContactNode = nil;
        Player *playerContactNode = nil;

        if (contact.bodyA.categoryBitMask == PlayerCategoryBitMask){
            multiplierContactNode = (Multiplier*)contact.bodyB.node;
            playerContactNode = (Player*)contact.bodyA.node;
        }
        else{
            multiplierContactNode = (Multiplier*)contact.bodyA.node;
            playerContactNode = (Player*)contact.bodyB.node;
        }

        if (multiplierContactNode.isContactVisible){
            self.scoreMultiplier+=[levelSettings[currentLevel][@"multiplierCount"] integerValue];

            //multiplier pop up
            [self popupWithString:[NSString stringWithFormat:@"x%ld", (long)_scoreMultiplier]
                       ofFontSize:appDelegate.defaultFontSize
                         andColor:multiplierContactNode.color
                       atPosition:player.position];

            [multiplierContactNode die];

            //PlayEffect(@"powerup2.wav");
        }
    }
    //Projectile - Wall
    else if ((contact.bodyA.categoryBitMask == ProjectileCategoryBitMask && contact.bodyB.categoryBitMask == WallCategoryBitMask) ||
             (contact.bodyA.categoryBitMask == WallCategoryBitMask && contact.bodyB.categoryBitMask == ProjectileCategoryBitMask)){
        Projectile *projectileContactNode = nil;

        if (contact.bodyA.categoryBitMask == ProjectileCategoryBitMask){
            projectileContactNode = (Projectile*)contact.bodyA.node;
        }
        else{
            projectileContactNode = (Projectile*)contact.bodyB.node;
        }

        [projectileContactNode die];
        [projectiles removeObject:projectileContactNode];
    }
}

#pragma mark - Touch Joysticks input

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches){
        CGPoint location = [touch locationInNode:self];

        if (!joystickLeftTouch && location.x < 0 && location.y < 200 && joystickLeft.userInteractionEnabled){
            joystickLeftTouch = touch;
            joystickLeft.position = location;
            [self.scene addChild:joystickLeft];
            [joystickLeft touchesBegan:[NSSet setWithObject:joystickLeftTouch] withEvent:event];
            continue;
        }
        if (!joystickRightTouch && location.x > 0 && location.y < 200 && joystickRight.userInteractionEnabled){
            joystickRightTouch = touch;
            joystickRight.position = location;
            [self.scene addChild:joystickRight];
            [joystickRight touchesBegan:[NSSet setWithObject:joystickRightTouch] withEvent:event];
            continue;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];

    for (UITouch *touch in touches){
        if (touch == joystickLeftTouch){
            [joystickLeft touchesEnded:[NSSet setWithObject:joystickLeftTouch] withEvent:event];
            [joystickLeft removeFromParent];
            joystickLeftTouch = nil;
            continue;
        }
        if (touch == joystickRightTouch){
            [joystickRight touchesEnded:[NSSet setWithObject:joystickRightTouch] withEvent:event];
            [joystickRight removeFromParent];
            joystickRightTouch = nil;
            continue;
        }
    }
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];

    for (UITouch *touch in touches){
        if (touch == joystickLeftTouch){
            [joystickLeft touchesCancelled:[NSSet setWithObject:joystickLeftTouch] withEvent:event];
            [joystickLeft removeFromParent];
            joystickLeftTouch = nil;
            continue;
        }

        if (touch == joystickRightTouch){
            [joystickRight touchesCancelled:[NSSet setWithObject:joystickRightTouch] withEvent:event];
            [joystickRight removeFromParent];
            joystickRightTouch = nil;
            continue;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];

    for (UITouch *touch in touches){
        if (touch == joystickLeftTouch){
            [joystickLeft touchesMoved:[NSSet setWithObject:joystickLeftTouch] withEvent:event];
            continue;
        }
        if (touch == joystickRightTouch){
            [joystickRight touchesMoved:[NSSet setWithObject:joystickRightTouch] withEvent:event];
            continue;
        }
    }
}

#pragma mark - PauseNode delegate

-(void)pauseResume{
    [self setUpUIForController];
    joystickLeft.userInteractionEnabled = YES;
    joystickRight.userInteractionEnabled = YES;
    
    //delay resume so user could get ready
    //slightly less with a gamepad
    NSInteger delay = .35;
    if (appDelegate.currentController)
        delay = .1;
    [self performSelector:@selector(resume) withObject:self afterDelay:delay];
}

-(void)pauseQuit{
    [self unloadLevel];
    [mainView switchToMainMenuSceneWithAnimationInForward:NO];
}

-(void)pauseRestart{
    [self setUpUIForController];
    [self restartLevel];
}

#pragma mark - LevelPassedNode delegate

-(void)levelPassedQuit{
    [self unloadLevel];
    [mainView switchToMainMenuSceneWithAnimationInForward:NO];
}

-(void)levelPassedRestart{
    [self setUpUIForController];
    [self restartLevel];
}

@end
