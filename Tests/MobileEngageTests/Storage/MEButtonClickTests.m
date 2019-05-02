//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSRequestModelBuilder.h"
#import "Kiwi.h"
#import "MEButtonClick.h"
#import "NSDate+EMSCore.h"

SPEC_BEGIN(MEButtonClickTests)

    describe(@"dictionaryRepresentation", ^{
        it(@"should return correct dictionary", ^{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:12345];
            MEButtonClick *click = [[MEButtonClick alloc] initWithCampaignId:@"123" buttonId:@"456" timestamp:date];
            [[[click dictionaryRepresentation] should] equal:@{
                    @"campaignId" : @"123",
                    @"buttonId" : @"456",
                    @"timestamp" : date.stringValueInUTC
            }];
        });
    });

SPEC_END
