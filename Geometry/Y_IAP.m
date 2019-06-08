//
//  Y_IAP.m
//  Doctor Who
//
//  Created by Ярослав Ерохин on 13.03.14.
//  Copyright (c) 2014 Ярослав Ерохин. All rights reserved.
//

#import "Y_IAP.h"

@implementation Y_IAP
+ (Y_IAP *)sharedInstance {
    static dispatch_once_t once;
    static Y_IAP * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"Dimensional.Ads.Remove",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

-(id)initWithProductIdentifiers:(NSSet *)productIdentifiers{
    if (self = [super initWithProductIdentifiers:productIdentifiers]){
        [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success)
                _products = products;
        }];
    }
    return self;
}
@end
