//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSDeepLinkInternal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"

@interface EMSDeepLinkInternal ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;

@end

@implementation EMSDeepLinkInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
    }
    return self;
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable EMSSourceHandler)sourceHandler {
    return [self trackDeepLinkWith:userActivity
                     sourceHandler:sourceHandler
               withCompletionBlock:nil];
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable EMSSourceHandler)sourceHandler
      withCompletionBlock:(EMSCompletionBlock)completionBlock {
    BOOL result = NO;
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSString *const webPageURL = userActivity.webpageURL.absoluteString;
        NSString *const queryNameDeepLink = @"ems_dl";
        NSURLQueryItem *queryItem = [self extractQueryItemFromUrl:webPageURL
                                                        queryName:queryNameDeepLink];
        if (queryItem) {
            result = YES;
            if (sourceHandler) {
                sourceHandler(webPageURL);
            }
            [self.requestManager submitRequestModel:[self.requestFactory createDeepLinkRequestModelWithTrackingId:queryItem.value ? queryItem.value : @""]
                                withCompletionBlock:completionBlock];
        }
    }
    return result;
}

- (NSURLQueryItem *)extractQueryItemFromUrl:(NSString *const)webPageURL
                                  queryName:(NSString *const)queryName {
    NSURLQueryItem *result;
    for (NSURLQueryItem *queryItem in [[NSURLComponents componentsWithString:webPageURL] queryItems]) {
        if ([queryItem.name isEqualToString:queryName]) {
            result = queryItem;
            break;
        }
    }
    return result;
}

@end
