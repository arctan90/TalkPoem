//
//  PoemListRequest.m
//  HackthonProject
//
//  Created by rick on 1/23/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "PoemListRequest.h"

@implementation PoemListRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setRequestUrl:@"poem/getList"];
        [self setRequestMethod:kHttpMethodGet];
        [self setRequestCacheType:kHttpCacheTypeLoadLocalCache];
        [self setPageNumber:1];
        [self setPageSize:200];
    }
    return self;
}

@end
