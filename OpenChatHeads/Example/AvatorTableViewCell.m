//
//  AvatorTableViewCell.m
//  OpenChatHeads
//
//  Created by 香象 on 29/11/13.
//  Copyright (c) 2013 香象. All rights reserved.
//

#import "AvatorTableViewCell.h"
#import "OpenDraggableView+TBAvatar.h"

@implementation AvatorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(OpenDraggableView *)draggableView{
    if (!_draggableView) {
        _draggableView = [OpenDraggableView tbDraggableViewWithImage:[UIImage imageNamed:@"MrTaoCircle"]];
        _draggableView.userInteractionEnabled=NO;
        [self.contentView addSubview:_draggableView];
    }
    return  _draggableView;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
