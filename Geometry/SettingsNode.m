//
//  SettingsNode.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 18.01.15.
//  Copyright (c) 2015 Yaroslav Erohin. All rights reserved.
//

#import "SettingsNode.h"
#import "AppDelegate.h"
#import "MainView.h"
#import "SKButton.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "Y_IAP.h"

@interface SettingsNode () <MFMailComposeViewControllerDelegate, AlertNodeDelegate>
@end

@implementation SettingsNode{
    NSMutableArray *buttons;
    int gamepadSelectedButtonIndex;
}
 
@synthesize delegate;

#pragma mark - Game controller methods

-(void)setupControllers{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate gamepadResetButtonsHandlers];

    if (appDelegate.currentController){
        [self setupGamepadButtons];
        //UI
        [self gamepadLegendSetVisible:YES];
    }
    else{
        [self gamepadLegendSetVisible:NO];
    }

    [self resetUI];
}

-(void)setupGamepadButtons{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    appDelegate.currentController.controllerPausedHandler = nil;
    appDelegate.currentController.extendedGamepad.buttonX.pressedChangedHandler = nil;
    appDelegate.currentController.extendedGamepad.buttonA.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
        if (pressed) { [self gamepadButtonSetSelected:YES]; } else { [self gamepadButtonClick]; }};
    appDelegate.currentController.extendedGamepad.buttonB.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
        if (!pressed) { [self close]; }};
    appDelegate.currentController.extendedGamepad.buttonY.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
        if (!pressed) { [self close]; }};
    appDelegate.currentController.extendedGamepad.dpad.up.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
        if (pressed) { [self gamepadMoveSelection:SKTransitionDirectionUp]; }};
    appDelegate.currentController.extendedGamepad.dpad.down.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
        if (pressed) { [self gamepadMoveSelection:SKTransitionDirectionDown]; }};
    appDelegate.currentController.extendedGamepad.dpad.left.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
        if (pressed) { [self gamepadMoveSelection:SKTransitionDirectionLeft]; }};
    appDelegate.currentController.extendedGamepad.dpad.right.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed){
        if (pressed) { [self gamepadMoveSelection:SKTransitionDirectionRight]; }};
}

-(void)gamepadLegendSetVisible:(BOOL)visible{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    if (visible){
        if (![self childNodeWithName:@"GamepadLegend"]){
            SKSpriteNode *legendNode = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:.85] size:CGSizeMake(211, 123)];
            legendNode.name = @"GamepadLegend";
            legendNode.alpha = 0;
            legendNode.position = CGPointMake(1030, 0);
            legendNode.anchorPoint = CGPointMake(1, .5);
            //71, 27.5 - nav Text baseline right
            //71, 46 - nav Img anchor: (1,0)

            SKLabelNode *navigationLabelNode = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
            navigationLabelNode.text = [NSLocalizedString(@"settings_navigation_title", @"Navigation label in the Settings Menu legend") uppercaseString];
            navigationLabelNode.fontSize = appDelegate.defaultFontSize;
            navigationLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
            navigationLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            navigationLabelNode.position = CGPointMake(-27.5, 27.5);
            [legendNode addChild:navigationLabelNode];

            SKSpriteNode *navigationSpriteNode = [SKSpriteNode spriteNodeWithTexture:[[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"gamepad_Dpad"]];
            navigationSpriteNode.size = CGSizeMake(19, 19);
            navigationSpriteNode.anchorPoint = CGPointMake(0, 0);
            navigationSpriteNode.position = CGPointMake(-173.5, 27.5);
            [legendNode addChild:navigationSpriteNode];

            SKLabelNode *selectLabelNode = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
            selectLabelNode.text = [NSLocalizedString(@"settings_select_title", @"Select label in the Settings Menu legend") uppercaseString];
            selectLabelNode.fontSize = appDelegate.defaultFontSize;
            selectLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            selectLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            selectLabelNode.position = CGPointMake(-27.5, 0);
            [legendNode addChild:selectLabelNode];

            SKSpriteNode *selectSpriteNode = [SKSpriteNode spriteNodeWithTexture:[[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"gamepad_ButtonA"]];
            selectSpriteNode.size = CGSizeMake(19, 19);
            selectSpriteNode.anchorPoint = CGPointMake(0, .5);
            selectSpriteNode.position = CGPointMake(-173.5, 0);
            [legendNode addChild:selectSpriteNode];

            SKLabelNode *cancelLabelNode = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
            cancelLabelNode.text = [NSLocalizedString(@"settings_cancel_title", @"Back label in the Settings Menu legend") uppercaseString];
            cancelLabelNode.fontSize = appDelegate.defaultFontSize;
            cancelLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
            cancelLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            cancelLabelNode.position = CGPointMake(-27.5, -48);
            [legendNode addChild:cancelLabelNode];

            SKSpriteNode *cancelSpriteNode = [SKSpriteNode spriteNodeWithTexture:[[SKTextureAtlas atlasNamed:@"UI"] textureNamed:@"gamepad_ButtonB"]];
            cancelSpriteNode.size = CGSizeMake(19, 19);
            cancelSpriteNode.anchorPoint = CGPointMake(0, 0);
            cancelSpriteNode.position = CGPointMake(-173.5, -48);
            [legendNode addChild:cancelSpriteNode];

            [self addChild:legendNode];
            [legendNode runAction:[SKAction fadeInWithDuration:.3]];
        }
    }
    else{
        SKSpriteNode *legendNode = (SKSpriteNode*)[self childNodeWithName:@"GamepadLegend"];
        [legendNode runAction:[SKAction fadeOutWithDuration:.3] completion:^{
            [legendNode removeFromParent];
        }];
    }
}

-(void)gamepadButtonSetSelected:(BOOL)selected{
    SKButton *button = buttons[gamepadSelectedButtonIndex];
    button.isSelected = selected;
    for (SKLabelNode *s in button.children){
        if (selected)
            s.fontColor = button.selectedColor;
        else
            s.fontColor = button.normalColor;
    }
}

-(void)gamepadButtonClick{
    SKButton *button = buttons[gamepadSelectedButtonIndex];
    if (button.isSelected)
        [button runTouchUpInsideAction];
    [self gamepadButtonSetSelected:NO];
}

-(void)gamepadMoveSelection:(SKTransitionDirection)direction{
    [self gamepadButtonSetSelected:NO];
    int buttonsCount = (int)buttons.count-1;
    if (direction == SKTransitionDirectionUp || direction == SKTransitionDirectionRight){
        if (gamepadSelectedButtonIndex == buttonsCount) gamepadSelectedButtonIndex = 0;
        else gamepadSelectedButtonIndex++;
    }
    else{
        if (gamepadSelectedButtonIndex == 0) gamepadSelectedButtonIndex = buttonsCount;
        else gamepadSelectedButtonIndex--;
    }
    [self reloadButtons];
}

-(void)reloadButtons{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    for (int i=0; i<buttons.count; i++){
        SKButton *button = buttons[i];
        if (i!=gamepadSelectedButtonIndex && appDelegate.currentController){
            [button runAction:[SKAction fadeAlphaTo:.6 duration:.1]];
            for (SKLabelNode *s in button.children){
                [s runAction:[SKAction fadeAlphaTo:.6 duration:.1]];
                break;
            }
        }
        else{
            [button runAction:[SKAction fadeAlphaTo:1 duration:.1]];
            for (SKLabelNode *s in button.children){
                [s runAction:[SKAction fadeAlphaTo:1 duration:.1]];
                break;
            }
        }
    }
}

#pragma mark - Node life cycle

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithPosition:(CGPoint)position{
    self = [super initWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:.85] size:CGSizeMake(763, 123)];
    if (self){
        self.zPosition = 10;
        self.name = @"SettingsNode";
        self.anchorPoint = CGPointMake(0, .5);

        //set position
        CGPoint dPoint = CGPointMake(-66, 18);
        self.position = addPoints(position, dPoint);

        //animation
        [self runAction:[SKAction moveByX:-self.size.width y:0 duration:0]];
        SKAction *animation = [SKAction moveByX:self.size.width y:0 duration:.25];
        animation.timingMode = UIViewAnimationOptionCurveEaseInOut;
        [self runAction:animation];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers) name:NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(provideContentForProductIdentifier:) name:IAPHelperProductPurchasedNotification object:nil];

        [self setupControllers];
    }
    return self;
}

-(void)resetUI{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    for (SKButton *s in buttons)
        [s removeFromParent];

    //SETTINGS BUTTON
    SKButton *settingsButton = [[SKButton alloc] initWithImageNamed:@"settingsMenu_SettingsButton" colorNormal:UI_COLOR_RED_BACK_NORMAL colorSelected:UI_COLOR_RED_BACK_SELECTED];
    settingsButton.size = CGSizeMake(-131, 123);
    settingsButton.zPosition = 2;
    settingsButton.position = CGPointMake(66, 0);
    [settingsButton setTouchUpInsideTarget:self action:@selector(closeButtonClicked)];

    SKLabelNode *settingsTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
    settingsTitle.fontSize = appDelegate.defaultFontSize;
    settingsTitle.text = [NSLocalizedString(@"settings_settings_title", @"Settings button title in the Settings Menu") uppercaseString];
    settingsTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    settingsTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    settingsTitle.position = CGPointMake(0, 28);
    settingsTitle.fontColor = settingsButton.color;
    [settingsButton addChild:settingsTitle];

//    MUSIC BUTTON
    NSString *musicButtonImageName = @"settingsMenu_MusicButton";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_MUSICENABLED])
        musicButtonImageName = @"settingsMenu_MusicButton";
    else musicButtonImageName = @"settingsMenu_MusicButton_disabled";

    SKButton *musicButton = [[SKButton alloc] initWithImageNamed:musicButtonImageName colorNormal:UI_COLOR_SETTINGS_MUSIC_NORMAL colorSelected:UI_COLOR_SETTINGS_MUSIC_SELECTED];
    musicButton.size = CGSizeMake(100, 123);
    musicButton.zPosition = 2;
    musicButton.position = CGPointMake(281, 0);
    [musicButton setTouchUpInsideTarget:self action:@selector(musicButtonClicked)];

    SKLabelNode *musicTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
    musicTitle.fontSize = appDelegate.defaultFontSize;
    musicTitle.text = [NSLocalizedString(@"settings_music_title", @"Music button title in the Settings Menu") uppercaseString];
    musicTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    musicTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    musicTitle.position = CGPointMake(0, 28);
    musicTitle.fontColor = musicButton.color;
    [musicButton addChild:musicTitle];

//    EFFECTS BUTTON
    NSString *effectsButtonImageName = @"settingsMenu_EffectsButton";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_EFFECTSENABLED])
        effectsButtonImageName = @"settingsMenu_EffectsButton";
    else effectsButtonImageName = @"settingsMenu_EffectsButton_disabled";

    SKButton *effectsButton = [[SKButton alloc] initWithImageNamed:effectsButtonImageName colorNormal:UI_COLOR_SETTINGS_EFFECTS_NORMAL colorSelected:UI_COLOR_SETTINGS_EFFECTS_SELECTED];
    effectsButton.size = CGSizeMake(100, 123);
    effectsButton.zPosition = 2;
    effectsButton.position = CGPointMake(181, 0);
    [effectsButton setTouchUpInsideTarget:self action:@selector(effectsButtonClicked)];

    SKLabelNode *effectsTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
    effectsTitle.fontSize = appDelegate.defaultFontSize;
    effectsTitle.text = [NSLocalizedString(@"settings_effects_title", @"Effects button title in the Settings Menu") uppercaseString];
    effectsTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    effectsTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    effectsTitle.position = CGPointMake(0, 28);
    effectsTitle.fontColor = effectsButton.color;
    [effectsButton addChild:effectsTitle];

    //SHARE BUTTON
    SKButton *shareButton = [[SKButton alloc] initWithImageNamed:@"settingsMenu_ShareButton" colorNormal:UI_COLOR_SETTINGS_SHARE_NORMAL colorSelected:UI_COLOR_SETTINGS_SHARE_SELECTED];
    shareButton.size = CGSizeMake(100, 123);
    shareButton.zPosition = 2;
    shareButton.position = CGPointMake(181, 0);
    [shareButton setTouchUpInsideTarget:self action:@selector(shareButtonClicked)];

    SKLabelNode *shareTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
    shareTitle.fontSize = appDelegate.defaultFontSize;
    shareTitle.text = [NSLocalizedString(@"settings_share_title", @"Share button title in the Settings Menu") uppercaseString];
    shareTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    shareTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    shareTitle.position = CGPointMake(0, 28);
    shareTitle.fontColor = shareButton.color;
    [shareButton addChild:shareTitle];

    //FEEDBACK BUTTON
    SKButton *feedbackButton = [[SKButton alloc] initWithImageNamed:@"settingsMenu_FeedbackButton" colorNormal:UI_COLOR_SETTINGS_FEEDBACK_NORMAL colorSelected:UI_COLOR_SETTINGS_FEEDBACK_SELECTED];
    feedbackButton.size = CGSizeMake(100, 123);
    feedbackButton.zPosition = 2;
    feedbackButton.position = CGPointMake(281, 0);
    [feedbackButton setTouchUpInsideTarget:self action:@selector(feedbackButtonClicked)];

    SKLabelNode *feedbackTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
    feedbackTitle.fontSize = appDelegate.defaultFontSize;
    feedbackTitle.text = [NSLocalizedString(@"settings_feedback_title", @"Feedback button title in the Settings Menu") uppercaseString];
    feedbackTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    feedbackTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    feedbackTitle.position = CGPointMake(0, 28);
    feedbackTitle.fontColor = feedbackButton.color;
    [feedbackButton addChild:feedbackTitle];

//    ABOUT BUTTON
    SKButton *aboutButton = [[SKButton alloc] initWithImageNamed:@"settingsMenu_AboutButton" colorNormal:UI_COLOR_SETTINGS_ABOUT_NORMAL colorSelected:UI_COLOR_SETTINGS_ABOUT_SELECTED];
    aboutButton.size = CGSizeMake(100, 123);
    aboutButton.zPosition = 2;
    aboutButton.position = CGPointMake(381, 0);
    [aboutButton setTouchUpInsideTarget:self action:@selector(aboutButtonClicked)];

    SKLabelNode *aboutTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
    aboutTitle.fontSize = appDelegate.defaultFontSize;
    aboutTitle.text = [NSLocalizedString(@"settings_about_title", @"About button title in the Settings Menu") uppercaseString];
    aboutTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    aboutTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    aboutTitle.position = CGPointMake(0, 28);
    aboutTitle.fontColor = aboutButton.color;
    [aboutButton addChild:aboutTitle];

    buttons = [NSMutableArray arrayWithObjects:settingsButton, shareButton, feedbackButton, nil];

//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Dimensional.Ads.Remove"]){
//        //REMOVE ADS BUTTON
//        SKButton *removeAdsButton = [[SKButton alloc] initWithImageNamed:@"settingsMenu_RemoveAdsButton" colorNormal:UI_COLOR_SETTINGS_REMOVEADS_NORMAL colorSelected:UI_COLOR_SETTINGS_REMOVEADS_SELECTED];
//        removeAdsButton.size = CGSizeMake(100, 123);
//        removeAdsButton.zPosition = 2;
//        removeAdsButton.position = CGPointMake(381, 0);
//        [removeAdsButton setTouchUpInsideTarget:self action:@selector(removeAdsButtonClicked)];
//
//        SKLabelNode *removeAdsTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
//        removeAdsTitle.fontSize = appDelegate.defaultFontSize;
//        removeAdsTitle.text = [NSLocalizedString(@"settings_remove_ads_title", @"Remove Ads Button Title") uppercaseString];
//        removeAdsTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
//        removeAdsTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
//        removeAdsTitle.position = CGPointMake(0, 28);
//        removeAdsTitle.fontColor = removeAdsButton.color;
//        [removeAdsButton addChild:removeAdsTitle];
//        [buttons addObject:removeAdsButton];
//
//        //RESTORE PURCHASES BUTTON
//        SKButton *restorePurchasesButton = [[SKButton alloc] initWithImageNamed:@"settingsMenu_RestorePurchasesButton" colorNormal:UI_COLOR_SETTINGS_RESTOREPURCHASES_NORMAL colorSelected:UI_COLOR_SETTINGS_RESTOREPURCHASES_SELECTED];
//        restorePurchasesButton.size = CGSizeMake(100, 123);
//        restorePurchasesButton.zPosition = 2;
//        restorePurchasesButton.position = CGPointMake(481, 0);
//        [restorePurchasesButton setTouchUpInsideTarget:self action:@selector(restorePurchases)];
//
//        SKLabelNode *restorePurchasesTitle = [SKLabelNode labelNodeWithFontNamed:appDelegate.defaultFontName];
//        restorePurchasesTitle.fontSize = appDelegate.defaultFontSize;
//        restorePurchasesTitle.text = [NSLocalizedString(@"settings_restore_title", nil) uppercaseString];
//        restorePurchasesTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
//        restorePurchasesTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
//        restorePurchasesTitle.position = CGPointMake(0, 28);
//        restorePurchasesTitle.fontColor = restorePurchasesButton.color;
//        [restorePurchasesButton addChild:restorePurchasesTitle];
//        [buttons addObject:restorePurchasesButton];
//
//        self.size = CGSizeMake(550, 123);
//    }
//    else {
        self.size = CGSizeMake(350, 123);
//    }

    [self reloadButtons];
    for (SKButton *s in buttons){
        [self addChild:s];
    }
}

#pragma mark - Buttons Methods

-(void)musicButtonClicked{
    NSString *imageName;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_MUSICENABLED]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USERDEFAULTS_MUSICENABLED];
        imageName = @"settingsMenu_MusicButton_disabled";
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_MUSICENABLED];
        imageName = @"settingsMenu_MusicButton";
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    ((SKButton*)[buttons objectAtIndex:2]).texture = [SKTexture textureWithImageNamed:imageName];
}

-(void)effectsButtonClicked{
    NSString *imageName;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_EFFECTSENABLED]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USERDEFAULTS_EFFECTSENABLED];
        imageName = @"settingsMenu_EffectsButton_disabled";
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_EFFECTSENABLED];
        imageName = @"settingsMenu_EffectsButton";
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    ((SKButton*)[buttons objectAtIndex:1]).texture = [SKTexture textureWithImageNamed:imageName];
}

-(void)shareButtonClicked{
    [self close];

    UIActivityViewController *vc = [[UIActivityViewController alloc]
                                    initWithActivityItems:@[NSLocalizedString(@"share_message", nil),
                                                            @"http://itunes.apple.com/us/app/apple-store/id947283667?mt=8",
                                                            @"#DimensionalGame",
                                                            [UIImage imageNamed:@"Share.jpg"]]
                                    applicationActivities:nil];

    //finding mainView
    id currentParent = self;
    while (![currentParent isKindOfClass:[MainView class]]){
        if ([currentParent parent]){
            currentParent = [currentParent parent];
        }
        else{
            currentParent = [currentParent view];
        }
    }

    vc.popoverPresentationController.sourceRect = CGRectMake(0, [currentParent frame].size.height, 1, 1);
    vc.popoverPresentationController.sourceView = currentParent;
    [[currentParent vc] presentViewController:vc animated:YES completion:nil];
}

-(void)feedbackButtonClicked{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    if (!appDelegate.currentController.isAttachedToDevice && appDelegate.currentController){
        for (SKButton *s in buttons){ s.isEnabled = NO; }
        MainView *mainView = (MainView*)self.scene.view;
        [mainView presentAlertNodeWithId:@"FEEDBACK_TOUCH_ALERT" title:NSLocalizedString(@"touch_controls_warning", @"you're currently using gamepad. but next action requires touch input") andDelegate:self];
    }
    else{
        [self sendFeedback];
    }
}

-(void)aboutButtonClicked{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Dimensional.Ads.Remove"];
}

-(void)removeAdsButtonClicked{
    if ([Y_IAP sharedInstance].products.count>0){
        SKProduct *product = (SKProduct*)[Y_IAP sharedInstance].products[0];

        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];

        for (SKButton *s in buttons){ s.isEnabled = NO; }
        MainView *mainView = (MainView*)self.scene.view;
        NSString *localizedFormatString = NSLocalizedString(@"remove_ads_dialog_title", nil);
        [mainView presentAlertNodeWithId:@"REMOVEADS_DIALOG" title:[NSString stringWithFormat:localizedFormatString, formattedPrice] andDelegate:self];
    }
}

-(void)restorePurchases{
    if ([Y_IAP sharedInstance].products.count>0){
        [[Y_IAP sharedInstance] restoreCompletedTransactions];
    }
}

-(void)closeButtonClicked{
    [self close];
}

#pragma mark - Other methods

-(void)closeSettings{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate gamepadResetButtonsHandlers];

    [self removeAllActions];
    SKAction *animation = [SKAction group:@[[SKAction moveByX:-self.size.width y:0 duration:.25], [SKAction fadeOutWithDuration:.2]]];
    animation.timingMode = UIViewAnimationOptionCurveEaseInOut;
    [self runAction:animation completion:^{
        [self removeFromParent];
    }];
}

-(void)sendFeedback{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        [composeViewController setToRecipients:@[@"ysoftware@yandex.ru"]];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setSubject:[NSString stringWithFormat:@"Letter to the author (dim:%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] ];
        [composeViewController setMessageBody:@"Hello Yaroslav, \n\n" isHTML:NO];
        if (composeViewController){
            [self.scene.view.window.rootViewController presentViewController:composeViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self close];
}

#pragma mark - Delegate call

-(void)close{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate gamepadResetButtonsHandlers];

    [self removeAllActions];
    SKAction *animation = [SKAction group:@[[SKAction moveByX:-self.size.width y:0 duration:.25], [SKAction fadeOutWithDuration:.2]]];
    animation.timingMode = UIViewAnimationOptionCurveEaseInOut;
    [self runAction:animation completion:^{
        [self removeFromParent];
        if ([self->delegate respondsToSelector:@selector(settingsDone)]){
            [self->delegate settingsDone];
        }
    }];
}

#pragma mark - In App Purcase Handler

-(void)provideContentForProductIdentifier:(NSNotification *)notification{
    NSString *identifier = [[notification userInfo] objectForKey:@"id"];

    if ([identifier isEqualToString:@"Dimensional.Ads.Remove"]){
        [self resetUI];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"remove_ads_done_title", nil)
                                                          message:NSLocalizedString(@"remove_ads_done_text", nil)
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];

        [message show];
    }
}

#pragma mark - AlertNode delegate

-(void)alertOKWithId:(NSString *)id{
    for (SKButton *s in buttons){ s.isEnabled = YES; }
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    if ([id isEqualToString:@"FEEDBACK_TOUCH_ALERT"]){
        [appDelegate gamepadResetButtonsHandlers];
        [self sendFeedback];
    }
    else if ([id isEqualToString:@"REMOVEADS_DIALOG"]){
        if ([Y_IAP sharedInstance].products.count>0){
            [[Y_IAP sharedInstance] buyProduct:[Y_IAP sharedInstance].products[0]];
        }
    }
    [self setupGamepadButtons];
}

-(void)alertCancelWithId:(NSString *)id{
    for (SKButton *s in buttons){ s.isEnabled = YES; }
    //    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if ([id isEqualToString:@"FEEDBACK_TOUCH_ALERT"]){
        //do nothing, ok
    }
    else if ([id isEqualToString:@"REMOVEADS_DIALOG"]){
        //do nothing, ok
    }
    [self setupGamepadButtons];
}

@end
