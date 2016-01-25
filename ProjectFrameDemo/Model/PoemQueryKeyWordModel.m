//
//  PoemQueryKeyWordModel.m
//  ProjectFrameDemo
//
//  Created by rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "PoemQueryKeyWordModel.h"

@implementation PoemQueryKeyWordModel
-(NSDictionary *)attrMapDict
{
    return @{@"message":@"Message",@"data":@"Data",@"statusCode":@"statusCode",@"poemID":@"id",@"title":@"title",@"abstract":@"abstract",@"text":@"text",@"content":@"content",@"questions":@"questions",@"options":@"options"};
}
@end
