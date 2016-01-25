//
//  IBBaseModel.m
//  ProjectFrameDemo
//
//  Created by Rick on 15/12/15.
//  Copyright © 2015年 XX_Company. All rights reserved.
//

#import "IB_BaseResponseModel.h"
#import "PoemQueryKeyWordModel.h"
#import "PoemKeyword.h"

@implementation IB_BaseResponseModel

-(NSDictionary *)attrMapDict
{
    return @{@"message":@"Message",@"data":@"Data",@"statusCode":@"statusCode",@"poemID":@"id",@"title":@"title",@"text":@"text",@"content":@"content",@"questions":@"questions",@"options":@"options"};
}

+ (Class)questions_class {
    return [PoemQueryKeyWordModel class];
}

+ (Class)options_class {
    return [PoemKeyword class];
}
@end
