//
//  PoemQueryKeyWordModel.h
//  ProjectFrameDemo
//
//  Created by rick on 1/22/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "IB_BaseDataModel.h"

@interface PoemQueryKeyWordModel : IB_BaseDataModel
@property (strong,nonatomic) NSString* title;
@property (strong,nonatomic) NSString* content;
@property (strong,nonatomic) NSString* abstract;
@property (strong,nonatomic) NSString* points;
@property (assign,nonatomic) NSInteger poemID;
@end
