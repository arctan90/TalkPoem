//
//  PoemListCell.m
//  HackthonProject
//
//  Created by rick on 1/23/16.
//  Copyright © 2016 XX_Company. All rights reserved.
//

#import "PoemListCell.h"
#import "PoemQueryKeyWordModel.h"

@interface PoemListCell()
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *contentLabel;
@end

@implementation PoemListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)fillCellWithObject:(PoemQueryKeyWordModel*)Poem {
    self.titleLabel.text = Poem.title;
    self.contentLabel.text = Poem.abstract;
}
@end
