//
//  CBAddReviewDelegate.m
//  gasp
//
//  Created by Mark Prichard on 1/19/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBAddReviewDelegate.h"
#import "CBGaspReviews.h"
#import "CBDeleteReviewDelegate.h"

static NSString *const HOST = @"http://gasp2.partnerdemo.cloudbees.net";

@implementation CBAddReviewDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Received: %@", response);
    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSLog(@"Location: %@", [headers objectForKey:@"Location"]);
    
    CBGaspReviews *client = [[CBGaspReviews alloc] init];
    CBDeleteReviewDelegate *callback = [[CBDeleteReviewDelegate alloc] init];
    [client DeleteReview:HOST withDelegate:callback withLocation:[headers objectForKey:@"Location"]];
}

@end
