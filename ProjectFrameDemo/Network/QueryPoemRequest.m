//
//  QueryPoemRequest.m
//  ProjectFrameDemo
//
//  Created by rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "QueryPoemRequest.h"

@implementation QueryPoemRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setRequestUrl:@"poem/queryById"];
        [self setRequestMethod:kHttpMethodGet];
        [self setRequestCacheType:kHttpCacheTypeLoadLocalCache];
//        [self setValue:@"2,4,10" forKey:@"ids"];
    }
    return self;
}

- (void)processResult:(IB_BaseResponseModel*)baseModel
{
}
@end
