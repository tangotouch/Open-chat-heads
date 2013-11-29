//
//  DraggableViewComponentInit.m
//  ChatHeads
//
//  Created by 香象 on 25/8/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "DraggableViewComponentInit.h"

#import "OpenDraggableView.h"
#import "OpenDraggableView+Avatar.h"
#import "OpenDraggableView+TBAvatar.h"
#import "RecentContactViewController.h"
#import "OpenDraggableView+TBAvatar.h"
#import "ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers.h"
#import "YQTChatViewController.h"
#import "ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers.h"



@implementation DraggableViewComponentInit


#pragma for notification


+(instancetype)sharedInstance{
    
    NSAssert([NSThread isMainThread], @"not support multi_thread");
    static id instance=nil;
    if(instance==nil){
        instance= [[self alloc]init];
    }
    return instance;
    
}


-(void)removeDraggableViewDynamiclyWithNick:(NSString *)nick{
    OpenDraggableView *draggableView= [self draggableViewForNick:nick];
    
    if (draggableView) {
        [self.draggingCoordinator removeDraggableViewDynamicly:draggableView];
    }
}



- (id)init
{
    self = [super init];
    if (self) {
        [self installNotification];
    }
    return self;
}

-(void)dealloc{
    [self uninstallNotification];
}



-(void)giveup:(NSNotification *)notification{
    
}

-(void)wangxingGiveup:(NSNotification *)notification{
    [[DraggableViewComponentInit sharedInstance].draggingCoordinator collapseConversation];
}

-(void)logout:(NSNotification *)notification{
    [[DraggableViewComponentInit sharedInstance].draggingCoordinator collapseConversation];
    [self closeMrTao];
}


- (void)addFriendRequest:(NSNotification*)notification{
    [self showMrTaoFirstTime];
    [self refreshBadgeUI:notification];
}

- (void)refreshBadgeUI:(NSNotification*)notification{

}



-(void)installNotification{
    [self uninstallNotification];
}




-(void)refreshUserListForUnbind{
    
}




-(void)refreshUserList{
    
}

-(void)uninstallNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



-(OpenDraggableView *)draggableViewForNick:(NSString *)nick{
    
    OpenDraggableView * draggableView=nil;
    for (OpenDraggableView *subView in self.draggingCoordinator.draggableViews) {
        
        if (![subView isKindOfClass:[OpenDraggableView class] ]) {
            //异常处理
            [self.draggingCoordinator.draggableViews removeObject:subView];
            continue;
        }
        NSString *identify =subView.uniqueIdentifier ;
        
        if ( ![identify isEqualToString:nick]) {
            continue;
        }
        
        draggableView= subView;
        break;
        
    }
    return draggableView;
}





-(OpenDraggableView *)userDraggableViewWithUser:( ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *) selectedUser{
    OpenDraggableView *draggableView = [OpenDraggableView tbDraggableViewWithImage:[UIImage imageNamed:@"MrTaoCircle"]];
    [draggableView configWithUser:selectedUser];
    draggableView.center=CGPointMake(250, -70);
    
    draggableView.uniqueIdentifier=selectedUser.nick;
    draggableView.viewControllerForConversationBlock=^(){
        YQTChatViewController *taobanChatViewController = [[YQTChatViewController alloc] init];
        taobanChatViewController.title=selectedUser.headPic;
        taobanChatViewController.imagePath=selectedUser.headPic;
        return taobanChatViewController;
    };
    return draggableView;
}



-(void)addAvator:( ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *) selectedUser{
    [self showMrTaoFirstTime];
    OpenDraggableView *draggableView = [self userDraggableViewWithUser:selectedUser];
    [[DraggableViewComponentInit sharedInstance].draggingCoordinator addDraggableView:draggableView isSilence:YES];
}



-(void)chatWithUser:( ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *) selectedUser{
    if (!selectedUser.nick) {
        return;
    }
    //CHDraggableView *draggableView = [CHDraggableView draggableViewWithImage:[UIImage imageNamed:@"avator.jpg"]];
    
    OpenDraggableView *draggableView = [self userDraggableViewWithUser:selectedUser];
    [[DraggableViewComponentInit sharedInstance].draggingCoordinator startConversationForDraggableViewIfNot:draggableView];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}


-(void)showMrTao{

    [self.draggingCoordinator startConversationForDraggableViewIfNot:self.mrTaoDraggableView];
    if (self.draggingCoordinator.draggableViewInConversation.viewControllerInConversation) {
        self.draggingCoordinator.presentedNavigationController.viewControllers=@[self.draggingCoordinator.draggableViewInConversation.viewControllerInConversation];
    }
}

-(void)closeMrTao{
    [self.draggingCoordinator closeAllDraggableView];
}

-(void)showMrTaoFirstTime{
        if (![self.draggingCoordinator.draggableViews containsObject:self.mrTaoDraggableView]) {
            [self.draggingCoordinator resetState];
            [self.draggingCoordinator addDraggableView:self.mrTaoDraggableView];
        }
}


-(OpenDraggableView *)mrTaoDraggableView{
    if (!_mrTaoDraggableView) {
        _mrTaoDraggableView = [OpenDraggableView tbDraggableViewWithImage:[UIImage imageNamed:@"MrTao"]];
        _mrTaoDraggableView.canNotDeletable = YES;
        _mrTaoDraggableView.uniqueIdentifier = MASTER_ID;
        //__unsafe_unretained 是不对的，必须这样，retain draggableView, 因为mrTaoDraggableView 在请求未读数取值时可能被release掉，所以必须retain
        
        OpenDraggableView* draggableView = _mrTaoDraggableView;
        NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)draggableView));
        NSLog(@"self count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
        

        NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)draggableView));
        NSLog(@"self count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
        
        _mrTaoDraggableView.viewControllerForConversationBlock=^(){
            RecentContactViewController *vc=[[RecentContactViewController alloc] init];
            vc.title = @"Group chat heads!";
            return vc;
        };
    }
    return _mrTaoDraggableView;
}

-(OpenGroupDraggingCoordinator *)draggingCoordinator{
    if (!_draggingCoordinator) {
        _draggingCoordinator = [[OpenGroupDraggingCoordinator alloc] initWithWindow:self.window draggableViewBounds:self.mrTaoDraggableView.bounds];
        _draggingCoordinator.delegate = self;
        _draggingCoordinator.maxNumberOfAvator=4;
        _draggingCoordinator.snappingEdge = TBGSnappingEdgeBoth;
    }
    return _draggingCoordinator;
}

- (void)draggingCoordinator:(OpenGroupDraggingCoordinator *)coordinator removedLastDraggableView:(OpenDraggableView *)draggableView{
    _mrTaoDraggableView = nil;
    
    
}

- (NSMutableArray *)draggingCoordinator:(OpenGroupDraggingCoordinator *)coordinator sortDraggableViews:(NSMutableArray *)draggableViews{
    return draggableViews;
}

- (UIViewController *)draggingCoordinator:(OpenGroupDraggingCoordinator *)coordinator viewControllerForDraggableView:(OpenDraggableView *)draggableView
{
    return nil;
}

- (void)draggingCoordinatorWillSwitch:(OpenGroupDraggingCoordinator *)coordinator{

}


@end
