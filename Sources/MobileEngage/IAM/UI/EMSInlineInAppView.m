//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInlineInAppView.h"
#import <WebKit/WebKit.h>
#import "EMSDependencyInjection.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSResponseModel.h"
#import "EMSIAMAppEventProtocol.h"
#import "EMSIAMCloseProtocol.h"
#import "MEIAMJSCommandFactory.h"
#import "MEJSBridge.h"
#import "NSError+EMSCore.h"
#import "EMSDispatchWaiter.h"

@interface EMSInlineInAppView () <WKNavigationDelegate, EMSIAMCloseProtocol>

@property(nonatomic, strong) WKWebView *webView;

@property(nonatomic, strong) IBInspectable NSString *viewId;
@property(nonatomic, strong) NSLayoutConstraint *selfHeightConstraint;
@property(nonatomic, strong) MEJSBridge *jsBridge;
@property(nonatomic, strong) MEIAMJSCommandFactory *commandFactory;
@property(nonatomic, strong) EMSEventHandlerBlock innerEventHandler;

@end

@implementation EMSInlineInAppView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    __weak typeof(self) weakSelf = self;
    EMSDispatchWaiter *waiter = [[EMSDispatchWaiter alloc] init];
    _innerEventHandler = ^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
        if (weakSelf.eventHandler) {
            weakSelf.eventHandler(eventName, payload);
        }
    };

    [waiter enter];

    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue addOperationWithBlock:^{
        weakSelf.commandFactory = [[MEIAMJSCommandFactory alloc] initWithMEIAM:EMSDependencyInjection.dependencyContainer.iam
                                                         buttonClickRepository:EMSDependencyInjection.dependencyContainer.buttonClickRepository
                                                          appEventHandlerBlock:weakSelf.innerEventHandler
                                                                 closeProtocol:weakSelf
                                                                    pasteboard:[UIPasteboard generalPasteboard]];
        weakSelf.jsBridge = [[MEJSBridge alloc] initWithJSCommandFactory:weakSelf.commandFactory
                                                          operationQueue:EMSDependencyInjection.dependencyContainer.coreOperationQueue];
        [weakSelf.jsBridge setJsResultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
            [weakSelf respondToJS:result];
        }];

        [waiter exit];
    }];

    [waiter waitWithInterval:3];
    self.webView = [self createWebView];
    self.selfHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:0];
    self.selfHeightConstraint.priority = UILayoutPriorityRequired;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self.webView stopLoading];
        [self.webView setNavigationDelegate:nil];
        [self.webView.scrollView setDelegate:nil];
        [self.webView.configuration.userContentController removeAllUserScripts];
        [self.webView.configuration setUserContentController:[WKUserContentController new]];
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
    [super willMoveToSuperview:newSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.webView) {
        [self addSubview:self.webView];
        [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.webView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.webView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.webView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.webView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:0];
        
        
        [NSLayoutConstraint activateConstraints:@[top, bottom, leading, trailing, self.selfHeightConstraint]];
        [self layoutIfNeeded];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self fetchInlineInappMessage];
}

- (WKWebView *)createWebView {
    WKProcessPool *processPool = [WKProcessPool new];
    WKWebViewConfiguration *webViewConfiguration = [WKWebViewConfiguration new];
    [webViewConfiguration setProcessPool:processPool];

    if (self.jsBridge) {
        [webViewConfiguration setUserContentController:self.jsBridge.userContentController];
    }

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                            configuration:webViewConfiguration];
    [webView setNavigationDelegate:self];
    [webView setOpaque:NO];
    [webView setBackgroundColor:UIColor.clearColor];
    [webView.scrollView setBackgroundColor:UIColor.clearColor];
    [webView.scrollView setScrollEnabled:NO];
    [webView.scrollView setBounces:NO];
    [webView.scrollView setBouncesZoom:NO];

    webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    return webView;
}

- (void)    webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [webView evaluateJavaScript:@"document.body.offsetHeight"
                  completionHandler:^(NSNumber *height, NSError *error) {
                      int htmlHeight = [height intValue];
                      int selfHeight = htmlHeight == 0 ? (int) weakSelf.webView.scrollView.contentSize.height : htmlHeight;
                      weakSelf.selfHeightConstraint.constant = selfHeight;
                      [weakSelf setHidden:NO];
                      [weakSelf layoutIfNeeded];

                      if (weakSelf.completionBlock) {
                          weakSelf.completionBlock(nil);
                      }
                  }];
    });
}

- (void)loadInAppWithViewId:(NSString *)viewId {
    _viewId = viewId;
    [self fetchInlineInappMessage];
}

- (void)fetchInlineInappMessage {
    if (self.viewId) {
        __weak typeof(self) weakSelf = self;
        [EMSDependencyInjection.dependencyContainer.coreOperationQueue addOperationWithBlock:^{
            EMSRequestFactory *requestFactory = EMSDependencyInjection.dependencyContainer.requestFactory;
            EMSRequestModel *requestModel = [requestFactory createInlineInappRequestModelWithViewId:weakSelf.viewId];
            [EMSDependencyInjection.dependencyContainer.requestManager submitRequestModelNow:requestModel
                                                                                successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                                                                    MEInAppMessage *inAppMessage = [weakSelf filterMessagesByViewId:response];
                                                                                    if (inAppMessage) {
                                                                                        [weakSelf.commandFactory setInAppMessage:inAppMessage];
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            [weakSelf.webView loadHTMLString:inAppMessage.html
                                                                                                                     baseURL:nil];
                                                                                        });
                                                                                    } else {
                                                                                        NSError *error = [NSError errorWithCode:-1400
                                                                                                           localizedDescription:@"Inline In-App HTML content must not be empty, please check your viewId!"];
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            if (weakSelf.completionBlock) {
                                                                                                weakSelf.completionBlock(error);
                                                                                            }
                                                                                        });
                                                                                    }
                                                                                }
                                                                                  errorBlock:^(NSString *requestId, NSError *error) {
                                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                                          [weakSelf setHidden:YES];
                                                                                          if (weakSelf.completionBlock) {
                                                                                              weakSelf.completionBlock(error);
                                                                                          }
                                                                                      });
                                                                                  }];
        }];
    }
}

- (MEInAppMessage *)filterMessagesByViewId:(EMSResponseModel *)response {
    MEInAppMessage *inAppMessage = nil;
    for (NSDictionary *message in response.parsedBody[@"inlineMessages"]) {
        if ([self.viewId.lowercaseString isEqualToString:((NSString *) message[@"viewId"]).lowercaseString]) {
            inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:message[@"campaignId"]
                                                                  sid:nil
                                                                  url:nil
                                                                 html:message[@"html"]
                                                    responseTimestamp:[NSDate date]];
        }
    }
    return inAppMessage;
}

- (void)closeInAppWithCompletionHandler:(EMSCompletion _Nullable)completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.closeBlock) {
            self.closeBlock();
        }
    });
}

- (void)respondToJS:(NSDictionary<NSString *, NSObject *> *)result {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result
                                                       options:0
                                                         error:&error];
    NSString *js = [NSString stringWithFormat:@"MEIAM.handleResponse(%@);",
                                              [[NSString alloc] initWithData:jsonData
                                                                    encoding:NSUTF8StringEncoding]];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.webView evaluateJavaScript:js
                           completionHandler:nil];
    });
}

@end
