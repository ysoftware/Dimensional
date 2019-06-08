//
//  GameViewController.h
//  Geometry
//

//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : UIViewController
-(BOOL)showAdsWithCompletionHandler:(void(^)(void))completion;
@end
