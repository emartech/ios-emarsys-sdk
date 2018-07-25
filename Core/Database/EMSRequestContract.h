//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//
#import "EMSRequestModelBuilder.h"

#define TABLE_NAME @"request"
#define COLUMN_NAME_REQUEST_ID @"request_id"
#define COLUMN_NAME_METHOD @"method"
#define COLUMN_NAME_URL @"url"
#define COLUMN_NAME_HEADERS @"headers"
#define COLUMN_NAME_PAYLOAD @"payload"
#define COLUMN_NAME_TIMESTAMP @"timestamp"
#define COLUMN_NAME_EXPIRY @"expiry"

#define SQL_CREATE_TABLE [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,%@ TEXT,%@ BLOB,%@ BLOB,%@ REAL,%@ DOUBLE);", TABLE_NAME, COLUMN_NAME_REQUEST_ID, COLUMN_NAME_METHOD, COLUMN_NAME_URL, COLUMN_NAME_HEADERS, COLUMN_NAME_PAYLOAD, COLUMN_NAME_TIMESTAMP, COLUMN_NAME_EXPIRY]
#define SQL_INSERT [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?);", TABLE_NAME, COLUMN_NAME_REQUEST_ID, COLUMN_NAME_METHOD, COLUMN_NAME_URL, COLUMN_NAME_HEADERS, COLUMN_NAME_PAYLOAD, COLUMN_NAME_TIMESTAMP, COLUMN_NAME_EXPIRY]
#define SQL_SELECTFIRST [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ROWID ASC LIMIT 1;", TABLE_NAME]
#define SQL_SELECTALL [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ROWID ASC;", TABLE_NAME]
#define SQL_DELETE_ITEM [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?;", TABLE_NAME, COLUMN_NAME_REQUEST_ID]
#define SQL_DELETE_MULTIPLE_ITEM(ids) [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ IN (%@);", TABLE_NAME, COLUMN_NAME_REQUEST_ID, ids]
#define SQL_PURGE [NSString stringWithFormat:@"DELETE FROM %@;", TABLE_NAME]
#define SQL_COUNT [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;", TABLE_NAME]

#define SCHEMA_UPGRADE_FROM_1_TO_2 [NSString stringWithFormat:@"ALTER TABLE request ADD COLUMN %@ DOUBLE;", COLUMN_NAME_EXPIRY]
#define SET_DEFAULT_VALUES_FROM_1_TO_2 [NSString stringWithFormat:@"UPDATE request SET expiry = %f;", DEFAULT_REQUESTMODEL_EXPIRY]