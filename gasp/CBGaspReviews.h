//
//  CBGaspReviews.h
//  gasp
//
//  Created by Mark Prichard on 1/9/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBGaspReviews : NSObject

- (NSString *) stringHttpGetContentsAtURL:(NSString *)url;
- (NSDictionary *) parseJSON:(NSString *)responseString;
- (NSArray *) parseJSONList:(NSString *)responseString;
- (NSArray *) listReviews:(NSString *)host;
- (NSString *) makeURL:(NSString *)url withPath:(NSString *)path;
- (void) addReview:(NSString *)host
      withDelegate: (id<NSURLConnectionDataDelegate>) callback
          withUser: (NSNumber *) theUser
    withRestaurant: (NSNumber *) theRestaurant
          withStar: (NSNumber *) starRating
      withComments: (NSString *) comment;
- (void) DeleteReview:(NSString *)host
         withDelegate: (id<NSURLConnectionDataDelegate>) callback
         withLocation: (NSString *) theReview;
+ (CBGaspReviews *)sharedNetworkClient;

@end
