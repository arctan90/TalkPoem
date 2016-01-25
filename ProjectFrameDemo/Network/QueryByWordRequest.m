//
//  QueryByWordRequest.m
//  ProjectFrameDemo
//
//  Created by rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "QueryByWordRequest.h"
#import "PoemQueryKeyWordModel.h"

@implementation QueryByWordRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setRequestUrl:@"poem/query"];
        [self setRequestMethod:kHttpMethodGet];
        [self setRequestCacheType:kHttpCacheTypeLoadLocalCache];
        [self setPageNumber:1];
        [self setPageSize:200];
    }
    return self;
}

- (void)processResult:(IB_BaseResponseModel*)baseModel
{
}
@end
