//
//  Y_IAP.h
//  Doctor Who
//
//  Created by Ярослав Ерохин on 13.03.14.
//  Copyright (c) 2014 Ярослав Ерохин. All rights reserved.
//

#import "IAPHelper.h"

@interface Y_IAP : IAPHelper
+ (Y_IAP *)sharedInstance;
@property (strong, nonatomic) NSArray *products;
@end
