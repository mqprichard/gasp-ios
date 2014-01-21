//
//  CBGaspReviews.m
//  gasp
//
//  Created by Mark Prichard on 1/9/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBGaspReviews.h"
#import "CBAddReviewDelegate.h"
#import <Foundation/Foundation.h>

@implementation CBGaspReviews

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

- (NSArray *) listReviews:(NSString *)host {
    NSString *data = [self stringHttpGetContentsAtURL:[self makeURL: host withPath:@"reviews"]];
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
            NSString* star = [[object objectAtIndex:i] valueForKey:@"star"];
            NSString* comment = [[object objectAtIndex:i] valueForKey:@"comment"];
            //NSLog(@"REVIEW Url: %@, Comment: %@, Star: %@", url, star, comment);
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

- (void) addReview:(NSString *)host
      withDelegate: (id<NSURLConnectionDataDelegate>) callback
          withUser: (NSNumber *) theUser
    withRestaurant: (NSNumber *) theRestaurant
          withStar: (NSNumber *) starRating
      withComments: (NSString *) comment {
    
    NSString* userString = [NSString stringWithFormat:@"%@%@%@", host, @"/user/", theUser];
    NSString* restString = [NSString stringWithFormat:@"%@%@%@", host, @"/restaurant/", theRestaurant];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: userString, @"user",
                          restString, @"restaurant",
                          starRating, @"star",
                          comment, @"comment",
                          nil];
    NSError *error;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    NSString *jsonSummary = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableString *json = [[NSMutableString alloc] init];
    [json setString:jsonSummary];
    [json replaceOccurrencesOfString:@"\\" withString:@"" options:0 range:NSMakeRange(0, [json length])];
    NSLog(@"%@", json);
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:[host stringByAppendingString:@"/reviews"]]];
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

+ (CBGaspReviews *)sharedNetworkClient {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
