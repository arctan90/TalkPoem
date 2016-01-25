//
//  PoemDetailViewController.h
//  HackthonProject
//
//  Created by rick on 1/23/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "IB_BaseViewController.h"
#import "PoemQueryKeyWordModel.h"
@interface PoemDetailViewController : IB_BaseViewController
@property (strong, nonatomic) PoemQueryKeyWordModel *poem;
@end
