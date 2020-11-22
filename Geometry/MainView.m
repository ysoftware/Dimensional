//
//  MainView.m
//  Geometry
//
//  Created by Ярослав Ерохин on 10.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "MainView.h"
#import "MainMenu.h"
#import "GameCenterManager.h"

@interface MainView () <GameCenterManagerDelegate>
@end

@implementation MainView{
    BackgroundNode *backgroundNode;
    CGSize sceneSize;
    UIEdgeInsets safeAreaInsets;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.allowsTransparency = NO;
        self.ignoresSiblingOrder = YES;
        [GameCenterManager sharedManager].delegate = self;


#if DEBUG
        self.showsFPS = YES;
        self.showsDrawCount = YES;
        self.showsNodeCount = YES;
//        self.showsPhysics = YES;
//        self.showsFields = YES;
#endif
    }
    return self;
}

- (void)setup {

    // set up background node
    SKNode *circlesNode = [[SKScene unarchiveFromFile: @"BackgroundScene"] childNodeWithName: @"root"];
    [circlesNode removeFromParent];
    backgroundNode = [[BackgroundNode alloc] initWithColor: [SKColor clearColor]
                                                      size: CGSizeMake(2048, 1536)
                                            andCirclesNode: circlesNode];
 
    // setup scene size
    CGSize size = self.bounds.size;
    sceneSize = CGSizeMake(1024, 1024/(size.width/size.height));
    CGFloat mult = size.height / sceneSize.height;
    safeAreaInsets = UIEdgeInsetsMake(self.layoutMargins.top * mult,
                                      self.layoutMargins.left * mult,
                                      self.layoutMargins.bottom * mult,
                                      self.layoutMargins.right * mult);

    [self switchToMainMenuSceneWithAnimationInForward:YES];
}

#pragma mark - Scenes

-(void)switchToLevelScene {
    LevelScene *levelScene = [[LevelScene alloc] initWithSize: sceneSize andEdgeInsets: safeAreaInsets];
    [backgroundNode removeFromParent];
    levelScene.scaleMode = SKSceneScaleModeAspectFill;
    levelScene.backgroundNode = backgroundNode;
    [levelScene addChild: backgroundNode];
    [self presentScene: levelScene];
}

-(void)switchToMainMenuSceneWithAnimationInForward:(BOOL)forward {
    MainMenu *mainMenuScene = [[MainMenu alloc] initWithSize:sceneSize];
    mainMenuScene.firstLoad = forward;
    [backgroundNode removeFromParent];
    mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
    mainMenuScene.backgroundNode = backgroundNode;
    [mainMenuScene addChild: backgroundNode];
    [self presentScene: mainMenuScene];
}

#pragma mark - Popover Nodes

-(void)presentPauseMenuWithDelegate:(id<PauseNodeDelegate>)delegate {
    PauseNode *node = [[PauseNode alloc] initWithEdgeInsets:safeAreaInsets];
    node.delegate = delegate;
    [self.scene addChild:node];
}

-(void)presentLevelPassedNodeWithScore:(NSInteger)score andDelegate:(id<LevelPassedNodeDelegate>)delegate {
    LevelPassedNode *node = [[LevelPassedNode alloc] initWithScore:score];
    node.delegate = delegate;
    [self.scene addChild:node];
}

-(void)presentSettingsNodeWithPosition:(CGPoint)position andDelegate:(id<SettingsNodeDelegate>)delegate {
    SettingsNode *node = [[SettingsNode alloc] initWithPosition:position];
    node.delegate = delegate;
    [self.scene addChild:node];
    node.zPosition = 10;
}

-(void)presentAlertNodeWithId:(NSString*)id title:(NSString*)title andDelegate:(id<AlertNodeDelegate>)delegate {
    AlertNode *node = [[AlertNode alloc] initWithTitle:[title uppercaseString]];
    node.delegate = delegate;
    node.id = id;
    [self.scene addChild:node];
    node.zPosition = 11;
}

#pragma mark - Game Center Manager delegate

-(void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    if ([self.scene isKindOfClass:[LevelScene class]]){
        LevelScene *scene = (LevelScene*)self.scene;
        if ([scene respondsToSelector:@selector(pause)])
            [scene pause];
    }

    [self.vc presentViewController:gameCenterLoginController animated:YES completion:nil];
}

-(void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error{
#ifdef DEBUG
    NSLog(@"mainView: GCM error: %@", error.localizedDescription);
#endif
}
@end
