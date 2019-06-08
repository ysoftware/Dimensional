//
//  MyAdsViewController.h
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.02.15.
//  Copyright (c) 2015 Yaroslav Erohin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAdsViewController : UIViewController

#define WHONIVERSE_ADNAME @"WHONIVERSE_AD"
#define GALLIFREYAN_ADNAME @"GALLIFREYAN_AD"

///Gallifreyan or Whoniverse

@property (strong, nonatomic) NSString *adName;
@end
