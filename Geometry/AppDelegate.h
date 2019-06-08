//
//  AppDelegate.h
//  Geometry
//
//  Created by Ярослав Ерохин on 08.07.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//
@import GameController;
@import AVFoundation;
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

#pragma mark - Constants and definitions

extern NSString* const PauseMenuScene;
extern NSString* const GameOverMenuScene;

//Units conversion
#define DEGREES_TO_RADIANS(degree) ((degree) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * 180.0 / M_PI)

#define IS_WIDESCREEN_IOS7 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_WIDESCREEN_IOS8 ( fabs( ( double )[ [ UIScreen mainScreen ] nativeBounds ].size.height - ( double )1136 ) < DBL_EPSILON )
#define IS_WIDESCREEN      ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_WIDESCREEN_IOS8 : IS_WIDESCREEN_IOS7 )
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

//Color conversion
#define PhotoshopColorValue(x) (x / 255.0)
#define SKColorFromPhotoshopRGBA(r,g,b,a) [SKColor colorWithRed:PhotoshopColorValue(r) green:PhotoshopColorValue(g) blue:PhotoshopColorValue(b) alpha:a]
#define SKColorFromPhotoshopHSBA(h,s,b,a) [SKColor colorWithHue:PhotoshopColorValue(h) saturation:PhotoshopColorValue(s) brightness:PhotoshopColorValue(b) alpha:a]
#define SKColorFromHexValue(hex) SKColorFromPhotoshopRGBA(((hex & 0xFF0000) >> 16), ((hex & 0xFF00) >> 8), (hex & 0xFF), 1.0)


@interface SKScene (Unarchive)
+ (instancetype)unarchiveFromFile:(NSString *)file;
@end

@interface SKEmitterNode (Unarchive)
+ (instancetype)unarchiveFromFile:(NSString*)file;
@end

@interface SKLabelNode (Animate)

///Format string must include one '%d'. If doesn't or is nil, will be default: @"%d".
-(void)animateTextWithFormat:(NSString*)format usingNumbersFrom:(NSInteger)startNumber To:(NSInteger)endNumber withDuration:(float)fullDuration usingNumberFormatter:(NSNumberFormatter*)formatter andCompletionBlock:(void (^)(void))completion;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

CGPoint pointAroundCircumferenceFromCenter(CGPoint center, CGFloat radius, CGFloat angle);
CGPoint addPoints(CGPoint p1, CGPoint p2);
CGFloat CGPointToDegree(CGPoint point);

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) AVAudioPlayer *musicPlayer;
@property (strong, nonatomic) GCController *currentController;

@property (strong, nonatomic) NSString *defaultFontNamePostScript;
@property (strong, nonatomic) NSString *defaultFontName;
@property (assign, nonatomic) float defaultFontSize;
@property (assign, nonatomic) float mediumFontSize;
@property (assign, nonatomic) float largeFontSize;

-(void)gamepadResetButtonsHandlers;
@end

