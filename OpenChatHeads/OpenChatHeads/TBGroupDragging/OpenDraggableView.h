//
//  CHDraggableView.h
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OpenDraggableViewDelegate;
@interface OpenDraggableView : UIView

@property (nonatomic, assign) id<OpenDraggableViewDelegate> delegate;
@property (nonatomic, strong) UIViewController *viewControllerInConversation;
@property (nonatomic, assign) BOOL canNotDeletable;
@property (nonatomic, strong) id uniqueIdentifier;
@property (nonatomic, strong) UIViewController * (^viewControllerForConversationBlock)();


- (void)snapViewCenterToPoint:(CGPoint)point edge:(CGRectEdge)edge;
- (void)snapViewCenterToPoint:(CGPoint)point edge:(CGRectEdge)edge completion:(void (^)(BOOL finished))completion;

@end

@protocol OpenDraggableViewDelegate <NSObject>

- (void)draggableViewHold:(OpenDraggableView *)view;
- (void)draggableView:(OpenDraggableView *)view didMoveToPoint:(CGPoint)point;
- (void)draggableViewReleased:(OpenDraggableView *)view;
- (void)draggableViewTouched:(OpenDraggableView *)view;
- (void)draggableViewNeedsAlignment:(OpenDraggableView *)view;
- (BOOL)draggableViewCanMove:(OpenDraggableView *)view;

@end