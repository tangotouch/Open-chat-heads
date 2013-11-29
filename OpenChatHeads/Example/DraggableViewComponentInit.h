//
//  DraggableViewComponentInit.h
//  ChatHeads
//
//  Created by 香象 on 25/8/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGroupDraggingCoordinator.h"

#define MASTER_ID @"MASTER_IDXXXX"

@class ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers;

@interface DraggableViewComponentInit : NSObject<UIApplicationDelegate,OpenDraggingCoordinatorDelegate>
@property (strong, nonatomic) OpenGroupDraggingCoordinator *draggingCoordinator;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OpenDraggableView *mrTaoDraggableView;




+(instancetype)sharedInstance;
-(void)showMrTao;
-(void)showMrTaoFirstTime;
-(void)chatWithUser:(ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *)selectedUser;
-(void)removeDraggableViewDynamiclyWithNick:(NSString *)nick;
@end
