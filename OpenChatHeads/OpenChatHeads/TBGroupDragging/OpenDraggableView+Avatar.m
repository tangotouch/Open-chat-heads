//
//  CHDraggableView+Avatar.m
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "OpenDraggableView+Avatar.h"

#import "OpenAvatarView.h"
#import "OpenDeletingDraggableView.h"
@implementation OpenDraggableView (Avatar)

+ (id)draggableViewWithImage:(UIImage *)image
{
    OpenDraggableView *view = [[OpenDraggableView alloc] initWithFrame:CGRectMake(0, 0, 58 , 58)];
    
    OpenAvatarView *avatarView = [[OpenAvatarView alloc] initWithFrame:CGRectInset(view.bounds, 0, 0)];
    avatarView.backgroundColor = [UIColor clearColor];
    [avatarView setImage:image];
    avatarView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    [view addSubview:avatarView];
    view.canNotDeletable=NO;
    
    return view;
}


@end
