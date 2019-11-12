//
//  ExampleWKWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "ExampleWKWebViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ExampleWKWebViewController ()

@property WebViewJavascriptBridge* bridge;
@property WKWebView* webView;

@end

@implementation ExampleWKWebViewController


- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) { return; }
    
    self.webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    
    __weak typeof(self) weakSelf = self;
    
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSString *userAgent = result;
        NSString *newUserAgent = [userAgent stringByAppendingString:@" IoPayAndroid IoPayiOs"];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        
        strongSelf.webView = [[WKWebView alloc] initWithFrame:strongSelf.view.bounds];
        
        // After this point the web view will use a custom appended user agent
        [strongSelf.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            NSLog(@"%@", result);
        }];
        
        
        strongSelf.webView.navigationDelegate = strongSelf;
        [strongSelf.view addSubview:strongSelf.webView];
        [WebViewJavascriptBridge enableLogging];
        _bridge = [WebViewJavascriptBridge bridgeForWebView:strongSelf.webView];
        [_bridge setWebViewDelegate:strongSelf];
        
        [_bridge registerHandler:@"get_account" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"get_account called: %@", data);
            responseCallback(@{ @"reqId":@"12" , @"address":@"io1q6heyxm5skdm4kt4y379adr7cjth0t7m5f42rz" });
        }];
        
        [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
        
        [strongSelf renderButtons:strongSelf.webView];
        [strongSelf loadExamplePage:strongSelf.webView];
        
    }];
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}

- (void)renderButtons:(WKWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(10, 400, 100, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(110, 400, 100, 35);
    reloadButton.titleLabel.font = font;
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(WKWebView*)webView {
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
//    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [webView loadHTMLString:appHtml baseURL:baseURL];

//    NSURL *memberUrl = [NSURL URLWithString:@"http://192.168.1.223:4008"];
    NSURL *memberUrl = [NSURL URLWithString:@"https://web-bp-dev.herokuapp.com/"];
    NSURLRequest *nSURLRequest = [NSURLRequest requestWithURL:memberUrl];
    [webView loadRequest:nSURLRequest];
}
@end
