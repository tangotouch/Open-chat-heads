//
//  CHDraggableView+TBAvatar.h
//  Taobao2013
//
//  Created by 香象 on 18/6/13.
//  Copyright (c) 2013 Taobao.com. All rights reserved.
//

#import "OpenDraggableView.h"
@class ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers;

@interface OpenDraggableView (TBAvatar)
+ (id)tbDraggableViewWithImage:(UIImage *)image;
- (void)setAvatarImageView:(UIImageView *)avatarImageView;
-(UIImageView *)avatarImageView;
-(void)configWithUser:( ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *) selectedUser;
+ (id)deletingDraggableViewWithImage:(UIImage *)image;

@end
