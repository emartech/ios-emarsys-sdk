//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSBlocks.h"

@interface EMSInlineInAppView: UIView

@property(nonatomic, strong) EMSEventHandlerBlock eventHandler;
@property(nonatomic, strong) EMSCompletionBlock completionBlock;
@property(nonatomic, strong) EMSInlineInappViewCloseBlock closeBlock;

- (void)loadInAppWithViewId:(NSString *)viewId;

@end
