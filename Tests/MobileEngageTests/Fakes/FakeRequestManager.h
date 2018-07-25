//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModel.h"
#import "EMSRequestManager.h"

@class EMSResponseModel;
@class XCTestExpectation;

@interface FakeRequestManager : EMSRequestManager

@property (nonatomic, strong) NSMutableArray<EMSRequestModel *> *submittedModels;
@property (nonatomic, strong) NSMutableArray<EMSResponseModel *> *responseModels;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *additionalHeaders;
@property (nonatomic, strong) CoreSuccessBlock successBlock;
@property (nonatomic, strong) CoreErrorBlock errorBlock;

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock;
- (void)waitForAllExpectations;

@end