//
//  CBDeleteReviewDelegate.h
//  gasp
//
//  Created by Mark Prichard on 1/19/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBDeleteReviewDelegate : NSObject <NSURLConnectionDataDelegate>
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
@end
