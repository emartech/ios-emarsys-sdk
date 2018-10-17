//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MERequestRepositoryProxy.h"
#import "MEButtonClickRepository.h"
#import "MEDisplayedIAMRepository.h"
#import "MERequestModelSelectEventsSpecification.h"
#import "EMSCompositeRequestModel.h"
#import "MERequestTools.h"
#import "MEButtonClickFilterNoneSpecification.h"
#import "MEDisplayedIAMFilterNoneSpecification.h"
#import "EMSDeviceInfo.h"
#import "MobileEngageVersion.h"
#import "MEInApp.h"
#import "MERequestContext.h"

@implementation MERequestRepositoryProxy

- (instancetype)initWithRequestModelRepository:(EMSRequestModelRepository *)requestModelRepository
                         buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                        displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                                         inApp:(MEInApp *)inApp
                                requestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestModelRepository);
    NSParameterAssert(buttonClickRepository);
    NSParameterAssert(displayedIAMRepository);
    NSParameterAssert(inApp);
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestModelRepository = requestModelRepository;
        _clickRepository = buttonClickRepository;
        _displayedIAMRepository = displayedIAMRepository;
        _inApp = inApp;
        _requestContext = requestContext;
    }
    return self;
}

- (void)add:(EMSRequestModel *)item {
    [self.requestModelRepository add:item];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self.requestModelRepository remove:sqlSpecification];
}

- (NSArray<EMSRequestModel *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    NSArray<EMSRequestModel *> *queriedArray = [self.requestModelRepository query:sqlSpecification];
    NSMutableArray<EMSRequestModel *> *resultModels = [NSMutableArray array];
    BOOL shouldCreateComposite = YES;

    for (EMSRequestModel *requestModel in queriedArray) {
        if ([self isCustomEvent:requestModel]) {
            if (shouldCreateComposite) {
                [resultModels addObject:[self createCompositeRequestModel:requestModel]];
                shouldCreateComposite = NO;
            }
        } else {
            [resultModels addObject:requestModel];
        }
    }

    return resultModels;
}

- (EMSRequestModel *)createCompositeRequestModel:(EMSRequestModel *)requestModel {
    NSArray *allCustomEvents = [self.requestModelRepository query:[MERequestModelSelectEventsSpecification new]];

    EMSCompositeRequestModel *composite = [EMSCompositeRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setHeaders:requestModel.headers];
            [builder setUrl:[[requestModel url] absoluteString]];

            NSMutableDictionary *payload = [NSMutableDictionary dictionary];
            payload[@"hardware_id"] = [EMSDeviceInfo hardwareId];
            payload[@"viewed_messages"] = [self displayRepresentations];
            payload[@"clicks"] = [self clickRepresentations];
            if ([self.inApp isPaused]) {
                payload[@"dnd"] = @([self.inApp isPaused]);
            }
            payload[@"events"] = [self eventRepresentations:allCustomEvents];

            payload[@"language"] = [EMSDeviceInfo languageCode];
            payload[@"ems_sdk"] = MOBILEENGAGE_SDK_VERSION;

            NSString *appVersion = [EMSDeviceInfo applicationVersion];
            if (appVersion) {
                payload[@"application_version"] = appVersion;
            }
            [builder setPayload:payload];
        }
                                                                  timestampProvider:self.requestContext.timestampProvider
                                                                       uuidProvider:self.requestContext.uuidProvider];
    composite.originalRequests = allCustomEvents;
    return composite;
}

- (NSArray *)eventRepresentations:(NSArray *)allCustomEvents {
    NSMutableArray *events = [NSMutableArray new];
    for (EMSRequestModel *model in allCustomEvents) {
        [events addObject:[model.payload[@"events"] firstObject]];
    }
    return [NSArray arrayWithArray:events];
}

- (NSArray *)clickRepresentations {
    NSArray<MEButtonClick *> *buttonModels = [self.clickRepository query:[MEButtonClickFilterNoneSpecification new]];
    NSMutableArray *clicks = [NSMutableArray new];
    for (MEButtonClick *click in buttonModels) {
        [clicks addObject:[click dictionaryRepresentation]];
    }
    return [NSArray arrayWithArray:clicks];
}

- (NSArray *)displayRepresentations {
    NSArray<MEDisplayedIAM *> *displayModels = [self.displayedIAMRepository query:[MEDisplayedIAMFilterNoneSpecification new]];
    NSMutableArray *viewedMessages = [NSMutableArray new];
    for (MEDisplayedIAM *display in displayModels) {
        [viewedMessages addObject:[display dictionaryRepresentation]];
    }
    return [NSArray arrayWithArray:viewedMessages];
}

- (BOOL)isCustomEvent:(EMSRequestModel *)requestModel {
    return [MERequestTools isRequestCustomEvent:requestModel];
}

- (BOOL)isEmpty {
    return [self.requestModelRepository isEmpty];
}

@end