//
//  CBGaspUsers.m
//  gasp
//
//  Created by Mark Prichard on 1/9/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBGaspUsers.h"
#import <Foundation/Foundation.h>

@implementation CBGaspUsers

- (NSString *) stringHttpGetContentsAtURL:(NSString *)url {
    NSURL *site = [NSURL URLWithString:url];
    return [NSString stringWithContentsOfURL:site encoding:NSUTF8StringEncoding error:NULL];
}


- (NSString *) makeURL:(NSString *)url withPath:(NSString *)path {
    return [url stringByAppendingPathComponent:path];
}

/*
 * fetch a (json) list of restaurants
 */

- (NSArray *) listUsers:(NSString *)host {
    NSString *data = [self stringHttpGetContentsAtURL:[self makeURL: host withPath:@"users"]];
    return [self parseJSONList:data];
}

/*
 * Convert JSON to an array we can use.
 */

- (NSArray *) parseJSONList:(NSString *)responseString {
    if (responseString == nil) return nil;
    NSData* data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if([object isKindOfClass:[NSArray class]]) {
        
        for (int i = 0; i < [object count]; i++) {
            NSString* url = [[object objectAtIndex:i] valueForKey:@"url"];
            NSString* name = [[object objectAtIndex:i] valueForKey:@"name"];
            NSLog(@"USER Url: %@, Name: %@", url, name);
        }
        
        return (NSArray *) object;
    } else {
        return nil;
    }
}

/*
 * Convert JSON to Dictionary we can use
 */

- (NSDictionary *) parseJSON:(NSString *)responseString {
    if (responseString == nil) return nil;
    NSData* data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if([object isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *) object;
    } else {
        return nil;
    }
}

- (void) AddUser:(NSString *)host
      withDelegate: (id<NSURLConnectionDataDelegate>) callback
      withName: (NSString *) name {
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: name, @"name", nil];
    NSError *error;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    NSString *jsonSummary = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableString *json = [[NSMutableString alloc] init];
    [json setString:jsonSummary];
    NSLog(@"%@", json);
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:[host stringByAppendingString:@"/users"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:callback];
    [connection start];
}

- (void) DeleteReview:(NSString *)host
         withDelegate: (id<NSURLConnectionDataDelegate>) callback
         withLocation: (NSString *) theReview {
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:theReview]];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:callback];
    [connection start];
}

/*
 * We only need one instance of this network client for the app.
 */

+ (CBGaspUsers *)sharedNetworkClient {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end
