//
//  MyAdsViewController.m
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.02.15.
//  Copyright (c) 2015 Yaroslav Erohin. All rights reserved.
//
@import StoreKit;
#import "AppDelegate.h"
#import "MyAdsViewController.h"

@interface MyAdsViewController () <SKStoreProductViewControllerDelegate>

@end

@implementation MyAdsViewController{
    UIButton *closeButton;
    UIActivityIndicatorView *activityIndicator;
}

#pragma mark - View controller life cycle

-(void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    //gradient background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[SKColorFromHexValue(0x041e33) CGColor], (id)[SKColorFromHexValue(0x01070d) CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    //Set Up
    UIImageView *iconImageView = [UIImageView new], *deviceImageView = [UIImageView new];

    UILabel *titleLabel = [UILabel new], *title2Label = [UILabel new], *textLabel = [UILabel new];
    textLabel.numberOfLines = 0;
    title2Label.numberOfLines = 0;
    titleLabel.textColor = [UIColor whiteColor];
    title2Label.textColor = [UIColor whiteColor];
    textLabel.textColor = [UIColor whiteColor];

    closeButton = [UIButton new];

    UIButton *actionButton = [UIButton new];
    [actionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [actionButton addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
    [actionButton addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpOutside];
    actionButton.layer.borderColor = self.view.tintColor.CGColor;
    [actionButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    actionButton.layer.cornerRadius = 4;

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator stopAnimating];

    //Content
    if ([self.adName isEqualToString:WHONIVERSE_ADNAME]){
        iconImageView.image = [UIImage imageNamed:@"whoniverse_icon"];
        deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"whoniverse_%@.jpg", IS_IPAD?@"ipad":@"iphone"]];
        [actionButton setTitle:[NSLocalizedString(@"ad_get", nil) uppercaseString] forState:UIControlStateNormal];
        titleLabel.text = @"WHONIVERSE";
        title2Label.text = [NSLocalizedString(@"whoniverse_ad_title", nil) uppercaseString];
        textLabel.text = NSLocalizedString(@"whoniverse_ad_text", nil);
    }
    else if ([self.adName isEqualToString:GALLIFREYAN_ADNAME]){

        iconImageView.image = [UIImage imageNamed:@"gallifreyan_icon"];
        deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gallifreyan_%@.jpg", IS_IPAD?@"ipad":@"iphone"]];
        [actionButton setTitle:[NSLocalizedString(@"ad_buy", nil) uppercaseString] forState:UIControlStateNormal];
        titleLabel.text = @"GALLIFREYAN";
        title2Label.text = [NSLocalizedString(@"gallifreyan_ad_title", nil) uppercaseString];
        textLabel.text = NSLocalizedString(@"gallifreyan_ad_text", nil);
    }

    //Positioning
    if (IS_IPAD){
        textLabel.font = [UIFont fontWithName:appDelegate.defaultFontNamePostScript size:appDelegate.defaultFontSize];
        title2Label.font = [UIFont fontWithName:appDelegate.defaultFontNamePostScript size:appDelegate.mediumFontSize];
        titleLabel.font = [UIFont fontWithName:@"Teko-Light" size:80];
        [actionButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];

        iconImageView.frame = CGRectMake(303, 47, 118, 118);
        deviceImageView.frame = CGRectMake(42, 268, 553, 373);
        titleLabel.frame = CGRectMake(443, 65, 500, 90);
        title2Label.frame = CGRectMake(637, 275, 376, 100);
        textLabel.frame = CGRectMake(637, 401, 376, 185);
        closeButton.frame = CGRectMake(16, 16, 30, 30);
        actionButton.frame = CGRectMake(637, 597, 18*actionButton.titleLabel.text.length, 39);
        actionButton.layer.borderWidth = 1.5;

        activityIndicator.frame = CGRectMake(actionButton.frame.origin.x + actionButton.frame.size.width + 16, actionButton.center.y - 20, 39, 39);
    }
    else{
        textLabel.font = [UIFont fontWithName:appDelegate.defaultFontNamePostScript size:20];
        title2Label.font = [UIFont fontWithName:appDelegate.defaultFontNamePostScript size:30];
        titleLabel.font = [UIFont fontWithName:@"Teko-Light" size:50];
        [actionButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:13]];

        closeButton.frame = CGRectMake(12, 12, 22, 22);

        float deviceImageHeight = self.view.bounds.size.height*.7;
        float deviceImageWidth = 542./752. * deviceImageHeight;
        deviceImageView.frame = CGRectMake(self.view.center.x - 16. - deviceImageWidth, self.view.bounds.size.height*.3, deviceImageWidth, deviceImageHeight);

        title2Label.frame = CGRectMake(self.view.center.x, self.view.bounds.size.height*.3, 250, 1);
        [title2Label sizeToFit];

        textLabel.frame = CGRectMake(self.view.center.x, title2Label.frame.origin.y + 16. + title2Label.frame.size.height, 250, 1);
        [textLabel sizeToFit];

        actionButton.frame = CGRectMake(self.view.center.x, self.view.bounds.size.height - 16. - 20, 14*actionButton.titleLabel.text.length, 20);
        actionButton.layer.borderWidth = 1;

        activityIndicator.frame = CGRectMake(actionButton.frame.origin.x + actionButton.frame.size.width + 16, actionButton.center.y - 10, 20, 20);

        float iconImageViewHeight = self.view.bounds.size.height*.15;
        iconImageView.frame = CGRectMake(self.view.center.x - 55 - iconImageViewHeight, (self.view.bounds.size.height*.3-iconImageViewHeight)/2, iconImageViewHeight, iconImageViewHeight);

        titleLabel.frame = CGRectMake(iconImageView.frame.origin.x + iconImageView.frame.size.width + 16, iconImageView.frame.origin.y, 200, iconImageViewHeight);
    }

    [self.view addSubview:iconImageView];
    [self.view addSubview:deviceImageView];
    [self.view addSubview:actionButton];
    [self.view addSubview:title2Label];
    [self.view addSubview:textLabel];
    [self.view addSubview:titleLabel];
    [self.view addSubview:activityIndicator];

    [closeButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    closeButton.enabled = NO;
    closeButton.alpha = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [UIView animateWithDuration:.4 delay:2.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self->closeButton.alpha = 1;
    } completion:^(BOOL finished) {
        self->closeButton.enabled = YES;
    }];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

-(void)buttonDown:(UIButton*)sender{
    UIColor *color = [UIColor blueColor];
    sender.layer.borderColor = color.CGColor;
    [sender setTitleColor:color forState:UIControlStateNormal];
}

-(void)buttonUp:(UIButton*)sender{
    sender.layer.borderColor = self.view.tintColor.CGColor;
    [sender setTitleColor:self.view.tintColor forState:UIControlStateNormal];
}

-(void)action:(UIButton*)sender{
    sender.layer.borderColor = self.view.tintColor.CGColor;
    [sender setTitleColor:self.view.tintColor forState:UIControlStateNormal];

    [activityIndicator startAnimating];
    SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc] init];
    storeVC.delegate = self;
    NSString *productId;
    if ([self.adName isEqualToString:WHONIVERSE_ADNAME])
        productId = @"821412407";
    else if ([self.adName isEqualToString:GALLIFREYAN_ADNAME])
        productId = @"926086199";

    if (IS_IPAD){
        [storeVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : productId} completionBlock:^(BOOL result, NSError *error) {
            if (error){
#ifdef DEBUG
                NSLog(@"myAdsViewController: error loading product: %@", error.localizedDescription);
#endif
            }
            else{
                [self presentViewController:storeVC animated:YES completion:nil];
            }
        }];
    }
    else{
        NSString *iTunesLink = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/apple-store/id%@?mt=8", productId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        [self dismiss];
    }

    [activityIndicator stopAnimating];
}

#pragma mark - SKStoreProductViewControllerDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
