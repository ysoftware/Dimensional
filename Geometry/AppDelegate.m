//
//  AppDelegate.m
//  Geometry
//
//  Created by Ярослав Ерохин on 08.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import "AppDelegate.h"
#import "GameCenterManager.h"
#import "MainView.h"
#import "Y_IAP.h"
#import "BackgroundNode.h"
//@import Firebase;

NSString* const PauseMenuScene = @"InGameMenu";
NSString* const GameOverMenuScene = @"GameOverMenu";

@implementation SKScene (Unarchive)
+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];

    return scene;
}
@end

@implementation SKEmitterNode (Unarchive)
+ (instancetype)unarchiveFromFile:(NSString*)file{
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    NSData *data = [NSData dataWithContentsOfFile:nodePath options:NSDataReadingMappedIfSafe error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKEmitterNode"];
    SKEmitterNode *node = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    return node;
}
@end

@implementation SKLabelNode (YE_Animate)
-(void)animateTextWithFormat:(NSString*)format
            usingNumbersFrom:(NSInteger)startNumber To:(NSInteger)endNumber
                withDuration:(float)fullDuration usingNumberFormatter:(NSNumberFormatter*)formatter
          andCompletionBlock:(void (^)(void))completion{

    if (fullDuration<0.034 && fullDuration>0){ fullDuration = 0.034; }
    if (format==nil || [format componentsSeparatedByString:@"%"].count!=2 || [format rangeOfString:@"%d"].location == NSNotFound)
    { format = @"%d"; }

    if (formatter){
        format = [format stringByReplacingOccurrencesOfString:@"%d" withString:@"%@"];
    }

    [self removeActionForKey:@"YE_AnimateTextWithNumbers"];
    NSMutableArray *animationsArray = [[NSMutableArray alloc] init];
    int changesCount = 30*fullDuration;
    float duration = fullDuration/changesCount;
    float formula = endNumber - startNumber;
    for (int i=1; i<=changesCount; i++){
        NSInteger number = roundf(startNumber+formula/changesCount*i);
        SKAction *basicTextChange = [SKAction sequence:@[[SKAction runBlock:^{
            if (formatter){
                NSString *stringFromNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:number]];
                self.text = [NSString stringWithFormat:format, stringFromNumber];
            }
            else{
                self.text = [NSString stringWithFormat:format, (int)number];
            }
        }], [SKAction waitForDuration:duration]]];
        [animationsArray addObject:basicTextChange];
    }
    SKAction *fullAnimations = [SKAction sequence:animationsArray];
    [self runAction:[SKAction sequence:@[fullAnimations, [SKAction runBlock:completion]]] withKey:@"YE_AnimateTextWithNumbers"];
}
@end

@implementation AppDelegate

#pragma mark - Application life cycle

void uncaughtExceptionHandler(NSException *exception) {
#ifdef DEBUG
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
#endif
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[GameCenterManager sharedManager] setupManagerAndSetShouldCryptWithKey:@"ysoftware-encrypted-key-string"];

    _largeFontSize = [NSLocalizedString(@"application_font_largesize", nil) floatValue];
    _mediumFontSize = [NSLocalizedString(@"application_font_mediumsize", nil) floatValue];
    _defaultFontSize = [NSLocalizedString(@"application_font_defaultsize", nil) floatValue];
    _defaultFontName = NSLocalizedString(@"application_font_name", nil);
    _defaultFontNamePostScript = NSLocalizedString(@"application_font_name_postscript", nil);

//    [FIRApp configure];

    if ([GCController class]){
        //Game Controller
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers:) name:GCControllerDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers:) name:GCControllerDidDisconnectNotification object:nil];
        [GCController startWirelessControllerDiscoveryWithCompletionHandler:nil];
    }

    return YES;
}

//LAUNCH AND 2ND FOREGROUND CALL
-(void)applicationDidBecomeActive:(UIApplication *)application{
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = NO;
}

//1ST FOREGROUND CALL
-(void)applicationWillEnterForeground:(UIApplication *)application{

}

//1ST BACKGROUND CALL
-(void)applicationWillResignActive:(UIApplication *)application{
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
}

//2ND BACKGROUND CALL
-(void)applicationDidEnterBackground:(UIApplication *)application{

}

#pragma mark - Game Controller

-(void)gamepadResetButtonsHandlers{
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appDelegate.currentController.extendedGamepad.dpad.up.pressedChangedHandler = nil;
    appDelegate.currentController.extendedGamepad.dpad.down.pressedChangedHandler = nil;
    appDelegate.currentController.extendedGamepad.dpad.left.pressedChangedHandler = nil;
    appDelegate.currentController.extendedGamepad.dpad.right.pressedChangedHandler = nil;

    appDelegate.currentController.extendedGamepad.buttonA.pressedChangedHandler = nil;
    appDelegate.currentController.extendedGamepad.buttonB.pressedChangedHandler = nil;
    appDelegate.currentController.extendedGamepad.buttonX.pressedChangedHandler = nil;
    appDelegate.currentController.extendedGamepad.buttonY.pressedChangedHandler = nil;

    appDelegate.currentController.controllerPausedHandler = nil;
}

-(void)setupControllers:(NSNotification*)notification{
    if (self.currentController){
        if (![[GCController controllers] containsObject:self.currentController]){
            self.currentController = nil; //Контроллер отключен, ищем другие
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED object:nil];
        }
        else{
            return; //Ничего не изменилось
        }
    }

    if ([GCController controllers].count>0){
        for (GCController *s in [GCController controllers]){
            if (s.extendedGamepad){ //Добавлены новые контроллеры, будем использовать первый попавшийся
                self.currentController = s;
                self.currentController.playerIndex = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GAMECONTROLLER_STATUS_CHANGED object:nil];
                break;
            }
        }
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:self.currentController!=nil];//не даём выключиться экрану
}

#pragma mark - Utilities

CGPoint addPoints(CGPoint p1, CGPoint p2){
    return (CGPoint){p1.x+p2.x, p1.y+p2.y};
}

CGPoint pointAroundCircumferenceFromCenter(CGPoint center, CGFloat radius, CGFloat angle){
    CGPoint point = CGPointZero;
    point.x = center.x + radius * cos(angle);
    point.y = center.y + radius * sin(angle);
    return point;
}

CGFloat CGPointToDegree(CGPoint point) {
    CGFloat bearingRadians = atan2f(point.y, point.x);
    CGFloat bearingDegrees = bearingRadians * (180. / M_PI);
    return bearingDegrees;
}
@end
