//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEDownloader.h"
#import "NSError+EMSCore.h"

@interface MEDownloader ()

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation MEDownloader

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setTimeoutIntervalForRequest:30.0];
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        [operationQueue setMaxConcurrentOperationCount:1];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:nil
                                            delegateQueue:operationQueue];

    }
    return self;
}

- (void)downloadFileFromUrl:(NSURL *)sourceUrl
          completionHandler:(DownloadTaskCompletionHandler)completionHandler {
    if (sourceUrl) {
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:sourceUrl
                                                         completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                             NSString *mimeType = [self valueWithDictionary:((NSHTTPURLResponse *) response).allHeaderFields
                                                                                          forInsensitiveKey:@"content-type"];
                                                             NSURL *mediaFileUrl = [self createLocalTempUrlWithFileType:mimeType];
                                                             if (!error) {
                                                                 if (location && mediaFileUrl) {
                                                                     [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                             toURL:mediaFileUrl
                                                                                                             error:&error];
                                                                     if (!error && completionHandler) {
                                                                         completionHandler(mediaFileUrl, nil);
                                                                         return;
                                                                     }

                                                                 } else {
                                                                     error = [NSError errorWithCode:1415
                                                                               localizedDescription:@"Unsupported file url."];
                                                                 }
                                                             }

                                                             if (completionHandler) {
                                                                 completionHandler(nil, error);
                                                             }
                                                         }];
        [task resume];
    } else {
        if (completionHandler) {
            completionHandler(nil, [NSError errorWithCode:1400
                                     localizedDescription:@"Source url doesn't exist."]);
        }
    }
}

- (NSURL *)createLocalTempUrlWithFileType:(NSString *)fileType {
    NSURL *mediaFileUrl;
    NSString *mediaFileName = [[NSUUID UUID] UUIDString];
    if (fileType) {
        NSString *extension = [fileType componentsSeparatedByString:@"/"].lastObject;
        if (extension) {
            mediaFileName = [NSString stringWithFormat:@"%@.%@", mediaFileName, extension];
        }
    }
    NSString *tmpSubFolderName = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *tmpSubFolderUrl = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:tmpSubFolderName];
    NSError *directoryCreationError;
    [[NSFileManager defaultManager] createDirectoryAtURL:tmpSubFolderUrl
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&directoryCreationError];

    if (!directoryCreationError && tmpSubFolderName && mediaFileName) {
        mediaFileUrl = [tmpSubFolderUrl URLByAppendingPathComponent:mediaFileName];
    }
    return mediaFileUrl;
}

- (nullable id)valueWithDictionary:(NSDictionary *)dictionary
                 forInsensitiveKey:(NSString *)key {
    id result = nil;
    for (id dictKey in dictionary.allKeys) {
        BOOL isString = [dictKey isKindOfClass:[NSString class]];
        if (isString && [[dictKey lowercaseString] isEqualToString:[key lowercaseString]]) {
            result = dictionary[dictKey];
            break;
        }
    }
    return result;
}

@end