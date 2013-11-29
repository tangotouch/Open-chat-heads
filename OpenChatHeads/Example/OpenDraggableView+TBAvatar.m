//
//  CHDraggableView+TBAvatar.m
//  Taobao2013
//
//  Created by 香象 on 18/6/13.
//  Copyright (c) 2013 Taobao.com. All rights reserved.
//

#import "OpenDraggableView+TBAvatar.h"
#import "OpenAvatarView.h"
#import <objc/runtime.h>
#import "ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers.h"
#import "OpenDeletingDraggableView.h"


static char avatarImageViewKey;

@implementation OpenDraggableView (TBAvatar)

- (void)setAvatarImageView:(UIImageView *)avatarImageView
{
    objc_setAssociatedObject(self, &avatarImageViewKey, avatarImageView, OBJC_ASSOCIATION_RETAIN);
}


-(UIImageView *)avatarImageView{
    UIImageView *_displayLink =objc_getAssociatedObject(self, &avatarImageViewKey);
    return _displayLink;
}

#define AVATOR_HEIGHT 60

+ (id)tbDraggableViewWithImage:(UIImage *)image
{
    OpenDraggableView *view = [[OpenDraggableView alloc] initWithFrame:CGRectMake(0, 0, AVATOR_HEIGHT, AVATOR_HEIGHT)];
    
    view.avatarImageView=[[UIImageView alloc]initWithFrame:CGRectInset(view.bounds, 0, 0)];
    view.avatarImageView.backgroundColor = [UIColor clearColor];
    [view.avatarImageView setImage:image];
    
    view.avatarImageView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    [view addSubview:view.avatarImageView];
    
    return view;
}

+ (id)deletingDraggableViewWithImage:(UIImage *)image
{
    OpenDeletingDraggableView *view = [[OpenDeletingDraggableView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    view.avatarImageView=[[UIImageView alloc]initWithFrame:CGRectInset(view.bounds, 0, 0)];
    view.avatarImageView.backgroundColor = [UIColor clearColor];
    [view.avatarImageView setImage:image];
    
    view.avatarImageView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    [view addSubview:view.avatarImageView];
    
    return view;
}

-(void)configWithUser:( ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *) selectedUser{
    if (selectedUser.headPic != nil){
        UIImageView *view= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, AVATOR_HEIGHT-8, AVATOR_HEIGHT-8)];
        view.contentMode=UIViewContentModeScaleAspectFit;
        view.clipsToBounds=YES;
        view.layer.cornerRadius=AVATOR_HEIGHT/2;
        view.image=[UIImage imageNamed:selectedUser.headPic];
        view.center=self.avatarImageView.center;
        [self insertSubview:view atIndex:0];

    }
}

@end
