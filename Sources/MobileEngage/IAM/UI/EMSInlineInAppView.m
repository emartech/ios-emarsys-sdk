//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInlineInAppView.h"
#import <WebKit/WebKit.h>

IB_DESIGNABLE

@interface EMSInlineInAppView () <WKNavigationDelegate>

@property(nonatomic, strong) WKWebView *webView;

@property(nonatomic, strong) IBInspectable NSString *viewId;
@property(nonatomic, strong) IBInspectable NSString *attributes;

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
    _webView = [self createWebView];
    self.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:self.webView];
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.webView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.webView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1
                                                             constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:0];
    [self addConstraints:@[top, left, widthConstraint, heightConstraint]];
    [self layoutIfNeeded];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.webView loadHTMLString:@"<!DOCTYPE html>\n"
                                 "<html>\n"
                                 "<head>\n"
                                 "\t<title>iia</title>\n"
                                 "</head>\n"
                                 "<body>\n"
                                 "\t<div style=\"height: 300px; background-color: red;\">\n"
                                 "\t\t<p>This is a test body for the awesome inline inapp</p>\t\t\n"
                                 "\t</div>\n"
                                 "</body>\n"
                                 "</html>"
                         baseURL:nil];
}

- (WKWebView *)createWebView {
    WKProcessPool *processPool = [WKProcessPool new];
    WKWebViewConfiguration *webViewConfiguration = [WKWebViewConfiguration new];
    [webViewConfiguration setProcessPool:processPool];
//    [webViewConfiguration setUserContentController:self.bridge.userContentController];

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
    self.hidden = NO;
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(nil);
        });
    }
}

- (void)loadInAppWithViewId:(NSString *)viewId {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initWithString:viewId]]];
}

@end
