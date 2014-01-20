//
//  ASService.m
//  gasp
//
//  Created by Mark Prichard on 1/20/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "ASService.h"

@implementation ASService

void(^getServerResponseForUrlCallback)(NSString *result, NSError *error);

NSString* returnResult = @"Return Data";
NSError* error;

- (void)getServerResponseForUrl:(NSString *)url withCallback:(ASCompletionBlock)callback
{
    NSLog(@"Url: %@", url);
    
    getServerResponseForUrlCallback = callback;
    [self onBackendResponse:nil error:nil];
}

- (void)onBackendResponse:(NSString *)result error:(NSError *)error
{
    getServerResponseForUrlCallback(returnResult, error);
}
@end
