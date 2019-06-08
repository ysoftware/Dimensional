//
//  IAPHelper.h
//  Doctor Who
//
//  Created by Ярослав Ерохин on 13.03.14.
//  Copyright (c) 2014 Ярослав Ерохин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IAPHelperProductPurchasedNotification @"IAPHelperProductPurchasedNotification"
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
@end
