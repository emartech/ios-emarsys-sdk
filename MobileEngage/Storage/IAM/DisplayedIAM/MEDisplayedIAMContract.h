//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#define TABLE_NAME_DISPLAYED_IAM @"displayed_iam"
#define COLUMN_NAME_CAMPAIGN_ID @"campaign_id"
#define COLUMN_NAME_TIMESTAMP @"timestamp"

#define SQL_CREATE_TABLE_DISPLAYED_IAM [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT, %@ DOUBLE);", TABLE_NAME_DISPLAYED_IAM, COLUMN_NAME_CAMPAIGN_ID, COLUMN_NAME_TIMESTAMP]
#define SQL_REQUEST_INSERT [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@) VALUES (?, ?);", TABLE_NAME_DISPLAYED_IAM, COLUMN_NAME_CAMPAIGN_ID, COLUMN_NAME_TIMESTAMP]
#define SQL_SELECT(filter) [NSString stringWithFormat:@"SELECT * FROM %@ %@;", TABLE_NAME_DISPLAYED_IAM, filter]
#define SQL_REQUEST_DELETE_ITEM(filter) [NSString stringWithFormat:@"DELETE FROM %@ %@;", TABLE_NAME_DISPLAYED_IAM, filter]
#define SQL_REQUEST_PURGE [NSString stringWithFormat:@"DELETE FROM %@;", TABLE_NAME_DISPLAYED_IAM]
#define SQL_REQUEST_COUNT [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;", TABLE_NAME_DISPLAYED_IAM]
