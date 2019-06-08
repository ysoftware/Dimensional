//
//  GameViewController.m
//  Geometry
//
//  Created by Ярослав Ерохин on 08.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

//@import GoogleMobileAds;
#import "MyAdsViewController.h"
#import "AppDelegate.h"
#import "GameViewController.h"
#import "MainMenu.h"
#import "LevelScene.h"
#import "MainView.h"
#import "Y_IAP.h"

@interface GameViewController ()
//@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation GameViewController{
    void (^adsActionCompletionHandler)(void);
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

    MainView *view = [[MainView alloc] initWithFrame:self.view.bounds];
    view.vc = self;
    [self.view addSubview:view];

    [self prepareAds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [Y_IAP sharedInstance];

    //default settings
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_EFFECTSENABLED])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_EFFECTSENABLED];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_MUSICENABLED])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_MUSICENABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)prepareAds{
//    if (![[Y_IAP sharedInstance] productPurchased:@"Dimensional.Ads.Remove"]) {
//        self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-4118201815139139/3464592403"];
//        GADRequest *request = [GADRequest request];
//        request.testDevices = @[ kGADSimulatorID, @"4df355416d5d7af3dd1d3a44458f815e" ];
//        [self.interstitial loadRequest:request];
//    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    // ads finished showing
    if (adsActionCompletionHandler){
        adsActionCompletionHandler();
        adsActionCompletionHandler = nil;
        [self prepareAds];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    NSString *MyAdName = WHONIVERSE_ADNAME;
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_HAVESHOWNADSBEFORE]){
//        MyAdName = WHONIVERSE_ADNAME;
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_HAVESHOWNADSBEFORE];
//    }
//    else{
//        int randomNumber = arc4random()%2;
//
//        if (randomNumber == 0){
//            MyAdName = WHONIVERSE_ADNAME;
//        }
//        else{
//            MyAdName = GALLIFREYAN_ADNAME;
//        }
//    }
//
//    ((MyAdsViewController*)segue.destinationViewController).adName = MyAdName;
}

// app id: ca-app-pub-4118201815139139~1987859205
// unit id: ca-app-pub-4118201815139139/3464592403

/// returns if paid ads are going to be shown
-(BOOL)showAdsWithCompletionHandler:(void(^)(void))completion{
//    if ([[Y_IAP sharedInstance] productPurchased:@"Dimensional.Ads.Remove"]) {
//        completion();
//        return NO;
//    }
//    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
//
//    if (appDelegate.currentController.isAttachedToDevice || !appDelegate.currentController){
//        BOOL willDisplayAds = self.interstitial.isReady;
//        if (willDisplayAds){
//            adsActionCompletionHandler = completion;
//            [self.interstitial presentFromRootViewController:self];
//#ifdef DEBUG
//            NSLog(@"gameViewController: displaying ads");
//#endif
//        }
//        else{
//            float longestGameTime = [[NSUserDefaults standardUserDefaults] floatForKey:USERDEFAULTS_LONGESTGAMETIME],
//            lastGameTime = [[NSUserDefaults standardUserDefaults] floatForKey:USERDEFAULTS_LASTGAMETIME];
//
//            BOOL shouldShowMyAds = lastGameTime >= longestGameTime || lastGameTime >= 40;
//            if (shouldShowMyAds){
//                adsActionCompletionHandler = completion;
//                [self performSegueWithIdentifier:@"ToMyAdVC" sender:self];
//#ifdef DEBUG
//                NSLog(@"gameViewController: showing My Ads");
//#endif
//            }
//            else{
//                adsActionCompletionHandler = nil;
//                completion();
//#ifdef DEBUG
//                NSLog(@"gameViewController: AdMob not in the mood");
//#endif
//            }
//        }
//        return willDisplayAds;
//    }
//    else{
//#ifdef DEBUG
//        NSLog(@"gameViewController: no ads with a game controller");
//#endif
//        completion();
//        return NO;
//    }
	return NO;
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
