//
//  MainView.h
//  Geometry
//
//  Created by Ярослав Ерохин on 10.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"
#import "AppDelegate.h"
#import "BackgroundNode.h"
#import "PauseNode.h"
#import "AlertNode.h"
#import "SettingsNode.h"
#import "LevelScene.h"
#import "LevelPassedNode.h"

//COLORS
#define UI_COLOR_GREEN_NEXT_NORMAL SKColorFromHexValue(0x00cb00)
#define UI_COLOR_GREEN_NEXT_SELECTED SKColorFromHexValue(0x00ff00)
#define UI_COLOR_RED_BACK_NORMAL SKColorFromHexValue(0xae0021)
#define UI_COLOR_RED_BACK_SELECTED SKColorFromHexValue(0xe00029)
#define UI_COLOR_ORANGE_STAY_NORMAL SKColorFromHexValue(0xccb100)
#define UI_COLOR_ORANGE_STAY_SELECTED SKColorFromHexValue(0xffdd00)
#define UI_COLOR_BLUE_NEUTRAL_NORMAL SKColorFromHexValue(0x155c85)
#define UI_COLOR_BLUE_NEUTRAL_SELECTED SKColorFromHexValue(0x2089c5)

#define UI_COLOR_SETTINGS_MUSIC_NORMAL SKColorFromHexValue(0xff4060)
#define UI_COLOR_SETTINGS_MUSIC_SELECTED SKColorFromHexValue(0xff8095)

#define UI_COLOR_SETTINGS_EFFECTS_NORMAL SKColorFromHexValue(0xff5f57)
#define UI_COLOR_SETTINGS_EFFECTS_SELECTED SKColorFromHexValue(0xff9c96)

#define UI_COLOR_SETTINGS_SHARE_NORMAL SKColorFromHexValue(0xffcc00)
#define UI_COLOR_SETTINGS_SHARE_SELECTED SKColorFromHexValue(0xffe580)

#define UI_COLOR_SETTINGS_FEEDBACK_NORMAL SKColorFromHexValue(0x4bda64)
#define UI_COLOR_SETTINGS_FEEDBACK_SELECTED SKColorFromHexValue(0x3dff5e)

#define UI_COLOR_SETTINGS_ABOUT_NORMAL SKColorFromHexValue(0x59cdff)
#define UI_COLOR_SETTINGS_ABOUT_SELECTED SKColorFromHexValue(0x99e0ff)

#define UI_COLOR_SETTINGS_REMOVEADS_NORMAL SKColorFromHexValue(0x59cdff)
#define UI_COLOR_SETTINGS_REMOVEADS_SELECTED SKColorFromHexValue(0x99e0ff)

#define UI_COLOR_SETTINGS_RESTOREPURCHASES_NORMAL SKColorFromHexValue(0x408cff)
#define UI_COLOR_SETTINGS_RESTOREPURCHASES_SELECTED SKColorFromHexValue(0x80b2ff)

#define BACKGROUND_COLOR_0 SKColorFromHexValue(0x000d26)
#define BACKGROUND_COLOR_1 SKColorFromHexValue(0x001029)
#define BACKGROUND_COLOR_2 SKColorFromHexValue(0x210500)
#define BACKGROUND_COLOR_3 SKColorFromHexValue(0x1a000e)
#define BACKGROUND_COLOR_4 SKColorFromHexValue(0x16001a)
#define BACKGROUND_COLOR_5 SKColorFromHexValue(0x1a0024)
#define BACKGROUND_COLOR_6 SKColorFromHexValue(0x001726)
#define BACKGROUND_COLOR_7 SKColorFromHexValue(0x00191a)
#define BACKGROUND_COLOR_8 SKColorFromHexValue(0x001a0a)
#define BACKGROUND_COLOR_9 SKColorFromHexValue(0x051f00)
#define BACKGROUND_COLOR_10 SKColorFromHexValue(0x1f001a)

#define FONT_COLOR_NEW_HIGHSCORE SKColorFromHexValue(0xd52242)
#define FONT_COLOR_LEADERBOARD_FRIEND SKColorFromHexValue(0xb552de)
#define FONT_COLOR_LEADERBOARD_ME SKColorFromHexValue(0x76dd4e)
#define FONT_COLOR_LEADERBOARD_1 SKColorFromHexValue(0xffffff)
#define FONT_COLOR_LEADERBOARD_2 SKColorFromHexValue(0xb3b3b3)

//CONSTANTS
#define USERDEFAULTS_ENEMIES_KILLED_TOTAL @"USERDEFAULTS_ENEMIES_KILLED_TOTAL"
#define USERDEFAULTS_MULTIPLIERS_GATHERED_TOTAL @"USERDEFAULTS_MULTIPLIERS_GATHERED_TOTAL"
#define USERDEFAULTS_LONGESTGAMETIME @"USERDEFAULTS_LONGESTGAMETIME"
#define USERDEFAULTS_LASTGAMETIME @"USERDEFAULTS_LASTGAMETIME"
#define USERDEFAULTS_HAVESHOWNADSBEFORE @"USERDEFAULTS_HAVESHOWNADSBEFORE"

#define USERDEFAULTS_MUSICENABLED @"USERDEFAULTS_MUSICENABLED"
#define USERDEFAULTS_EFFECTSENABLED @"USERDEFAULTS_EFFECTSENABLED"

#define NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED @"NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED"

///Plays effect with using given string file name on caller's scene property.
//#define PlayEffect(withFileNamed) if ([[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_EFFECTSENABLED]) [self.scene runAction:[SKAction playSoundFileNamed:withFileNamed waitForCompletion:NO]];

@interface MainView : SKView
@property (strong, nonatomic) GameViewController *vc;

/**YES = game launch -> menu scene.

 NO = menu scene <- level selector/level scene*/
-(void)switchToMainMenuSceneWithAnimationInForward:(BOOL)forward;

///Switch to Endless Run Scene
-(void)switchToLevelScene;

-(void)presentPauseMenuWithDelegate:(id<PauseNodeDelegate>)delegate;
-(void)presentLevelPassedNodeWithScore:(NSInteger)score andDelegate:(id<LevelPassedNodeDelegate>)delegate;
///Position: center of the settings button
-(void)presentSettingsNodeWithPosition:(CGPoint)position andDelegate:(id<SettingsNodeDelegate>)delegate;
-(void)presentAlertNodeWithId:(NSString*)id title:(NSString*)title andDelegate:(id<AlertNodeDelegate>)delegate;
@end