//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSTimestampProvider.h"
#import "EMSRequestModelBuilder.h"
#import "Kiwi.h"
#import "MEIAMCleanupResponseHandler.h"
#import "EMSAbstractResponseHandler+Private.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSUUIDProvider.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMIAMCleanup.db"]

SPEC_BEGIN(MEIAMCleanupResponseHandlerTests)

        __block EMSTimestampProvider *timestampProvider;
        __block EMSRequestModel *requestModel;

        beforeEach(^{
            timestampProvider = [EMSTimestampProvider new];
            requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"https://mobile-events.eservice.emarsys.net/v3/devices/meid/events"];
                }
                                          timestampProvider:[EMSTimestampProvider new]
                                               uuidProvider:[EMSUUIDProvider new]];
        });

        describe(@"MEIAMCleanupResponseHandler.shouldHandleResponse", ^{

            it(@"should return YES when the response contains old_messages and the array contains more than 0 ids", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789]}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:requestModel
                                                                                timestamp:[NSDate date]];

                MEIAMCleanupResponseHandler *handler = [MEIAMCleanupResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beYes];
            });

            it(@"should return NO when the request URL is not the V3 event service endpoint URL", ^{
                EMSRequestModel *nonV3EventRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.emarsys.com"];
                    }
                                                                         timestampProvider:[EMSTimestampProvider new]
                                                                              uuidProvider:[EMSUUIDProvider new]];

                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@1234, @56789, @"245678"]}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:nonV3EventRequestModel
                                                                                timestamp:[NSDate date]];

                MEIAMCleanupResponseHandler *handler = [MEIAMCleanupResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response contains old_messages and the array is empty", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"old_messages": @[]} options:0 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:requestModel
                                                                                timestamp:[NSDate date]];

                MEIAMCleanupResponseHandler *handler = [MEIAMCleanupResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response lacks old_messages", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"nothing": @[@"something"]}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:requestModel
                                                                                timestamp:[NSDate date]];

                MEIAMCleanupResponseHandler *handler = [MEIAMCleanupResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

            it(@"should return NO when the response contains not an array under key old_messages", ^{
                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @{@"1234": @56789}}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:requestModel
                                                                                timestamp:[NSDate date]];

                MEIAMCleanupResponseHandler *handler = [MEIAMCleanupResponseHandler new];

                [[theValue([handler shouldHandleResponse:response]) should] beNo];
            });

        });

        describe(@"MEIAMCleanupResponseHandler.handleResponse", ^{

            __block EMSSQLiteHelper *_dbHelper;

            beforeEach(^{
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH error:nil];
                _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                           schemaDelegate:[EMSSqliteSchemaHandler new]];
                [_dbHelper open];
            });


            afterEach(^{
                [_dbHelper close];
            });

            it(@"should remove the Clicks matching the returned IDs", ^{
                MEButtonClickRepository *repository = [[MEButtonClickRepository alloc] initWithDbHelper:_dbHelper];

                [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id1"
                                                                 buttonId:@"b"
                                                                timestamp:[NSDate date]]];
                [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id2"
                                                                 buttonId:@"b"
                                                                timestamp:[NSDate date]]];
                [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id3"
                                                                 buttonId:@"b"
                                                                timestamp:[NSDate date]]];
                [repository add:[[MEButtonClick alloc] initWithCampaignId:@"id4"
                                                                 buttonId:@"b"
                                                                timestamp:[NSDate date]]];


                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@"id2", @"id4"]}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                MEIAMCleanupResponseHandler *handler = [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:repository
                                                                                                     displayIamRepository:nil];
                [handler handleResponse:response];

                NSArray<MEButtonClick *> *clicks = [repository query:[EMSFilterByNothingSpecification new]];

                [[theValue([clicks count]) should] equal:theValue(2)];
                [[[clicks[0] campaignId] should] equal:@"id1"];
                [[[clicks[1] campaignId] should] equal:@"id3"];
            });

            it(@"should remove the Displays matching the returned IDs", ^{
                MEDisplayedIAMRepository *repository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:_dbHelper];

                [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id2a" timestamp:[NSDate date]]];
                [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id1a" timestamp:[NSDate date]]];
                [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id3a" timestamp:[NSDate date]]];
                [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:@"id4a" timestamp:[NSDate date]]];


                NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"oldCampaigns": @[@"id2a", @"id4a"]}
                                                               options:0
                                                                 error:nil];
                EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                  headers:@{}
                                                                                     body:body
                                                                             requestModel:[EMSRequestModel nullMock]
                                                                                timestamp:[NSDate date]];

                MEIAMCleanupResponseHandler *handler = [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:nil
                                                                                                     displayIamRepository:repository];
                [handler handleResponse:response];

                NSArray<MEDisplayedIAM *> *displays = [repository query:[EMSFilterByNothingSpecification new]];

                [[theValue([displays count]) should] equal:theValue(2)];
                [[[displays[0] campaignId] should] equal:@"id1a"];
                [[[displays[1] campaignId] should] equal:@"id3a"];
            });

        });

SPEC_END
