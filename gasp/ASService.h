//
//  ASService.h
//  gasp
//
//  Created by Mark Prichard on 1/20/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

// ASService.h

#import <Foundation/Foundation.h>

@interface ASService : NSObject

typedef void (^ASCompletionBlock)(NSString *data, NSError *error);

- (void)getServerResponseForUrl:(NSString *)url withCallback:(ASCompletionBlock)callback;

@end
