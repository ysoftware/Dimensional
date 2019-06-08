//
//  IAPHelper.m
//  Doctor Who
//
//  Created by Ярослав Ерохин on 13.03.14.
//  Copyright (c) 2014 Ярослав Ерохин. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>


@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {

    if ((self = [super init])) {

        // Store product identifiers
        _productIdentifiers = productIdentifiers;

        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
#ifdef DEBUG
                NSLog(@"Previously purchased: %@", productIdentifier);
#endif
            } else {
#ifdef DEBUG
                NSLog(@"Not purchased: %@", productIdentifier);
#endif
            }
        }

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {

    // 1
    _completionHandler = [completionHandler copy];

    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    _productsRequest = nil;
    NSArray * skProducts = response.products;

    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
#ifdef DEBUG
    //NSLog(@"Failed to load list of products.");
#endif
    _productsRequest = nil;

    _completionHandler(NO, nil);
    _completionHandler = nil;
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
#ifdef DEBUG
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
#endif

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:[[NSDictionary alloc] initWithObjects:@[productIdentifier] forKeys:@[@"id"]]];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
@end