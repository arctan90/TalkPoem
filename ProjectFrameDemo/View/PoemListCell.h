//
//  PoemListCell.h
//  HackthonProject
//
//  Created by rick on 1/23/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "IB_BaseCell.h"
@class PoemQueryKeyWordModel;
@interface PoemListCell : IB_BaseCell
- (void)fillCellWithObject:(PoemQueryKeyWordModel*)Poem;
@end
