//
//  GameViewController.m
//  Geometry
//
//  Created by Ярослав Ерохин on 08.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "AppDelegate.h"
#import "GameViewController.h"
#import "MainMenu.h"
#import "LevelScene.h"
#import "MainView.h"

@interface GameViewController ()
@end

@implementation GameViewController{
}

#pragma mark - View Controller life cycle

-(void)willResignActive:(NSNotification*)notification{
    SKView *view = (SKView*)self.view;
    view.paused = YES;
    view.scene.paused = YES;
}

-(void)didBecomeActive:(NSNotification*)notification{
    SKView *view = (SKView*)self.view;
    view.paused = NO;
    view.scene.paused = NO;
}

-(void)viewDidLoad{
    [super viewDidLoad];

    MainView *view = [[MainView alloc] initWithFrame: self.view.bounds];
    view.vc = self;
    [self.view addSubview:view];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    //default settings
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_EFFECTSENABLED])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_EFFECTSENABLED];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_MUSICENABLED])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_MUSICENABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Settings

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
