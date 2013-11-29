//
//  TBDraggingCoordinator.m
//  ChatHeads
//
//  Created by 香象 on 25/8/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "OpenGroupDraggingCoordinator.h"
#import "UIViewController+Deprecated.h"


#import <QuartzCore/QuartzCore.h>
#import "OpenDraggableView.h"
#import "OpenDraggableView+Avatar.h"
#import "OpenDraggableView+TBAvatar.h"

#import "OpenDeletingDraggableView.h"
#import "SKBounceAnimation.h"
#import "CAAnimation+Blocks.h"


#define OldPoint @"oldPoint"


typedef enum {
    TBInteractionStateNormal,
    TBInteractionStateConversation
} TBInteractionState;

@interface OpenGroupDraggingCoordinator ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableDictionary *edgePointDictionary;;
@property (nonatomic, assign) CGRect draggableViewBounds;
@property (nonatomic, assign) TBInteractionState state;


@property (nonatomic, strong) UIControl *backgroundView;
@property (nonatomic, strong) UIViewController *presentContainerViewController;
@property (nonatomic, strong) UIImageView *navArrowImageView;
@property (nonatomic, strong) UIViewController *viewControllerPresented;


@property (nonatomic, strong)  OpenDeletingDraggableView *deletingDraggableView;

@property (nonatomic, strong)  CADisplayLink *displayLink;

@property (nonatomic, assign)  float systemVersion;


@end

@implementation OpenGroupDraggingCoordinator

#define FrameInterval 10


-(float)systemVersion{
    if (!_systemVersion) {
        _systemVersion = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
    }
    return _systemVersion;
}


-(CADisplayLink *)displayLink{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerAction:)];
        _displayLink.frameInterval=FrameInterval;
        _displayLink.paused=YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return _displayLink;
}

- (void)startTimer
{
    self.displayLink.paused=NO;
}


- (void)stopTimer
{
    _displayLink.paused=YES;
    [_displayLink invalidate];
    _displayLink = nil;
}


-(void)timerAction:(id)data{

    if (!self.presentContainerViewController.presentedViewController) {
        [self.presentContainerViewController.view removeFromSuperview];
        [self stopTimer];
    }
}




-(UIImageView *)navArrowImageView{
    if (!_navArrowImageView) {
        [UIImage imageNamed:@"NavArrow"];
        _navArrowImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NavArrow"]];
        _navArrowImageView.frame=CGRectMake(0, -9+1, 12, 9) ;
    }
    return _navArrowImageView;
}

-(OpenDeletingDraggableView *)deletingDraggableView{
    if (!_deletingDraggableView) {
        _deletingDraggableView = [OpenDeletingDraggableView deletingDraggableViewWithImage:[UIImage imageNamed:@"MrTaoClose"]];
        _deletingDraggableView.userInteractionEnabled=NO;
        _deletingDraggableView.hiddingCenter=CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height+self.deletingDraggableView.bounds.size.height*2);
        _deletingDraggableView.showingCenter=CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height-self.deletingDraggableView.bounds.size.height*2);
    }
    return _deletingDraggableView;
}


- (id)initWithWindow:(UIWindow *)window draggableViewBounds:(CGRect)bounds
{
    self = [super init];
    if (self) {
        _window = window;
        _draggableViewBounds = bounds;
        _state = TBInteractionStateNormal;
        
    }
    return self;
}

-(NSMutableDictionary *)edgePointDictionary{
    if (!_edgePointDictionary) {
        _edgePointDictionary = [NSMutableDictionary dictionary];
    }
    return _edgePointDictionary;
}


-(void)dealloc{
}



-(void)notifyFullControllerWillClosed{
    [_presentContainerViewController.view removeFromSuperview];
}

#pragma mark - Geometry

- (CGRect)_dropArea
{
    return CGRectInset([self.window.screen applicationFrame], -(int)(CGRectGetWidth(_draggableViewBounds)/6), 0);
}

- (CGRect)_conversationArea
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide([self.window.screen applicationFrame], &slice, &remainder, CGRectGetHeight(CGRectInset(_draggableViewBounds, -10, 0)), CGRectMinYEdge);
    return slice;
}

- (CGRectEdge)_destinationEdgeForReleasePointInCurrentState:(CGPoint)releasePoint
{
    if (_state == TBInteractionStateConversation) {
        return CGRectMinYEdge;
    } else if(_state == TBInteractionStateNormal) {
        return releasePoint.x < CGRectGetMidX([self _dropArea]) ? CGRectMinXEdge : CGRectMaxXEdge;
    }
    NSAssert(false, @"State not supported");
    return CGRectMinYEdge;
}

- (CGPoint)destinationPointForReleasePoint:(CGPoint)releasePoint{
    return [self _destinationPointForReleasePoint:releasePoint];
}

- (CGPoint)_destinationPointForReleasePoint:(CGPoint)releasePoint
{
    CGRect dropArea = [self _dropArea];
    
    CGFloat midXDragView = CGRectGetMidX(_draggableViewBounds);
    CGRectEdge destinationEdge = [self _destinationEdgeForReleasePointInCurrentState:releasePoint];
    CGFloat destinationY;
    CGFloat destinationX;
    
    CGFloat topYConstraint = CGRectGetMinY(dropArea) + CGRectGetMidY(_draggableViewBounds);
    CGFloat bottomYConstraint = CGRectGetMaxY(dropArea) - CGRectGetMidY(_draggableViewBounds);
    if (releasePoint.y < topYConstraint) { // Align ChatHead vertically
        destinationY = topYConstraint;
    }else if (releasePoint.y > bottomYConstraint) {
        destinationY = bottomYConstraint;
    }else {
        destinationY = releasePoint.y;
    }
    
    if (self.snappingEdge == TBGSnappingEdgeBoth){   //ChatHead will snap to both edges
        if (destinationEdge == CGRectMinXEdge) {
            destinationX = CGRectGetMinX(dropArea) + midXDragView;
        } else {
            destinationX = CGRectGetMaxX(dropArea) - midXDragView;
        }
        
    }else if(self.snappingEdge == TBGSnappingEdgeLeft){  //ChatHead will snap only to left edge
        destinationX = CGRectGetMinX(dropArea) + midXDragView;
        
    }else{  //ChatHead will snap only to right edge
        destinationX = CGRectGetMaxX(dropArea) - midXDragView;
    }
    
    return CGPointMake(destinationX, destinationY);
}


-(NSMutableArray *)draggableViews{
    if (!_draggableViews) {
        _draggableViews= [[NSMutableArray alloc]init];
    }
    return _draggableViews;
}



-(BOOL)addDraggableView:(OpenDraggableView *)draggableView  isSilence:(BOOL)isSilence{
    if (![draggableView isKindOfClass:[OpenDraggableView class] ]) {
        return NO;
    }
    
    OpenDraggableView *destDraggableView=[self _addDraggableView:draggableView];
    switch (_state) {
        case TBInteractionStateConversation:
        {
            [self _showDraggableViewsWithCompletionBlock:^{
                if (!isSilence) {
                    [self _switchViewControllerForDraggableView:destDraggableView];
                } else{
                    //Refresh navArrowImageView position
                    [self moveNavArrowImageViewWhileDraggableView:self.draggableViewInConversation];
                }
            }];
            break;
        }
        case TBInteractionStateNormal:
        {
            [self _showDraggableViewsWithCompletionBlock:^{
                
    
            }];
            break;
        }
        default:
            break;
    }
    return NO;
}




-(BOOL)addDraggableView:(OpenDraggableView *)draggableView{
    return   [self addDraggableView:draggableView isSilence:NO];
}

-(OpenDraggableView *)_firstDraggableView{
    OpenDraggableView *targetDraggableView=nil;
    if (self.draggableViews.count&&[self.delegate respondsToSelector:@selector(draggingCoordinator:sortDraggableViews:)]) {
        self.draggableViews=[self.delegate draggingCoordinator:self sortDraggableViews:self.draggableViews];
    }

    for ( OpenDraggableView * draggableView in self.draggableViews) {
        if (draggableView.canNotDeletable==YES) {
            continue;
        }
        targetDraggableView=draggableView;
        break;
    }
    return targetDraggableView;
}



-(OpenDraggableView *)_addDraggableView:(OpenDraggableView *)draggableView{
    OpenDraggableView *targetDraggableView=nil;
    // add the newly avator.
    if (![self.draggableViews containsObject:draggableView]) {
        //remove the last avator for limiation.
        if (self.draggableViews.count==self.maxNumberOfAvator) {
            OpenDraggableView *removedraggableView=[self _firstDraggableView];
            
            if (_state==TBInteractionStateConversation) {
                CGPoint point=removedraggableView.center;
                point=CGPointMake(point.x-70, point.y-70);
                
                [removedraggableView snapViewCenterToPoint:point edge:CGRectMinXEdge completion:^(BOOL finished) {
                    if (finished) {
                        [removedraggableView removeFromSuperview];
                    }
                }];
                
            } else{
                [removedraggableView removeFromSuperview];
                
            }
            
            removedraggableView.delegate=nil;
            [self.draggableViews removeObject:removedraggableView];
        }
        
        draggableView.delegate=self;
        [self.draggableViews addObject:draggableView];
        targetDraggableView= draggableView;

        
    } else{
        NSUInteger oldObjectIndex= [self.draggableViews indexOfObject:draggableView];
        targetDraggableView=  [self.draggableViews objectAtIndex:oldObjectIndex];
    }
    
    return targetDraggableView;
}


-(BOOL)startConversationForDraggableViewIfNot:(OpenDraggableView *)draggableView{
    if (![draggableView isKindOfClass:[OpenDraggableView class] ]) {
        return NO;
    }
    
    OpenDraggableView *destDraggableView=[self _addDraggableView:draggableView];
    
    switch (_state) {
        case TBInteractionStateConversation:
        {
            [self _showDraggableViewsWithCompletionBlock:^{
                [self _switchViewControllerForDraggableView:destDraggableView];

            }];
            break;
        }
        case TBInteractionStateNormal:
        {
            _state =TBInteractionStateConversation;
            [self _showDraggableViewsWithCompletionBlock:^{
                [self _presentViewControllerForDraggableView:destDraggableView];
            }];

            break;
        }
        default:
            break;
    }
    return YES;
}



-(void)removeDraggableViewDynamicly:(OpenDraggableView *)draggableView{
    if ([self.draggableViews containsObject:draggableView]) {
        
        draggableView.delegate=nil;
        draggableView.viewControllerInConversation=nil;
        
        switch (_state) {
            case TBInteractionStateConversation:
            {
                if (self.draggableViewInConversation==draggableView) {
                    [self.draggableViews removeObject:draggableView];
                    if (self.draggableViews.count>0) {
                        self.draggableViewInConversation=[self.draggableViews lastObject];
                        [self _showDraggableViewsWithCompletionBlock:^{
                            [self _switchViewControllerForDraggableView:self.draggableViewInConversation];
                        }];
                    }
                    
                } else{
                    [self.draggableViews removeObject:draggableView];
                    [self _showDraggableViewsWithCompletionBlock:^{
                        [self moveNavArrowImageViewWhileDraggableView:self.draggableViewInConversation];
                    }];
                }
                
                break;
            }
            case TBInteractionStateNormal:
            {
                //                _state =TBInteractionStateConversation;
                [self.draggableViews removeObject:draggableView];
                [self _showDraggableViewsWithCompletionBlock:^{
                    
                }];
                break;
            }
            default:
                break;
        }
        
        [draggableView snapViewCenterToPoint:self.deletingDraggableView.hiddingCenter edge:CGRectMinXEdge completion:^(BOOL finished) {
            
            [draggableView removeFromSuperview];
            
        }];
        
        if (!self.draggableViews.count&&[self.delegate respondsToSelector:@selector(draggingCoordinator:removedLastDraggableView:)]) {
            [self.delegate draggingCoordinator:self removedLastDraggableView:draggableView];
            
        }
    }
}

-(void)resetState{
    _state =TBInteractionStateNormal;
    _edgePointDictionary=nil;
}


-(void)_readdDraggableViewInView:(UIView *)containerView{
    
    if (self.draggableViews.count&&[self.delegate respondsToSelector:@selector(draggingCoordinator:sortDraggableViews:)]) {
        self.draggableViews=[self.delegate draggingCoordinator:self sortDraggableViews:self.draggableViews];
    }
    
    for (OpenDraggableView *draggableView in self.draggableViews) {
        if (self.presentedNavigationController.view.superview) {
            [containerView insertSubview:draggableView belowSubview:self.presentedNavigationController.view];
        } else{
            [containerView addSubview:draggableView];
        }
    }
    
}
-(void)_showDraggableViewsInView:(UIView *)containerView completionBlock:(void (^)(void))block{
    
    [self _readdDraggableViewInView:containerView];
    
    switch (_state) {
        case TBInteractionStateNormal:
            [self _collapseConversation];
            break;
        case TBInteractionStateConversation:
        {
            [self _showDraggableViewsAtConversationWithCompletionBlock:^{
                if (block) {
                    block();
                }
                
            }];
            break;
        }
        default:
            break;
    }
}


#define GAPS 1
#define Right_Margin 10+6
#define Top_Margin 20

-(void)_showDraggableViewsAtConversationWithCompletionBlock:(void (^)(void))block{
    
    CGFloat screenWidth= self.window.frame.size.width;
    [CATransaction begin];
    for (NSUInteger i=self.draggableViews.count; i>0; i--) {
        OpenDraggableView *draggableView= [self.draggableViews objectAtIndex:self.draggableViews.count-i];
        CGFloat draggableViewWidth=draggableView.bounds.size.width;
        CGPoint center=CGPointMake(screenWidth-Right_Margin-draggableViewWidth/2-(i-1)*(draggableViewWidth+GAPS), Top_Margin+draggableViewWidth/2);
        
        [draggableView snapViewCenterToPoint:center edge:[self _destinationEdgeForReleasePointInCurrentState:draggableView.center]];
    }
    [CATransaction setCompletionBlock:^{
        if (block) {
            block();
            NSLog(@"The action is completed.");
        }
    }];
    [CATransaction commit];
}


-(void)_showDraggableViewsWithCompletionBlock:(void (^)(void))block{
    [self _showDraggableViewsInView:self.window completionBlock:block];
}


-(void)showDeletingDraggableView{
    if (!self.deletingDraggableView.isVisiable) {
        self.deletingDraggableView.isVisiable=YES;
        self.deletingDraggableView.center=self.deletingDraggableView.hiddingCenter;
        //        [self.window addSubview:self.deletingDraggableView];
        UIView *firstView= [self.draggableViews objectAtIndex:0];
        [self.window insertSubview:self.deletingDraggableView belowSubview:firstView];
        
        [self.deletingDraggableView snapViewCenterToPoint:self.deletingDraggableView.showingCenter edge:[self _destinationEdgeForReleasePointInCurrentState:self.deletingDraggableView.center]];
    }
}


-(void)hideDeletingDraggableView{
    if (self.deletingDraggableView.isVisiable) {
        self.deletingDraggableView.isVisiable=NO;
        [self.deletingDraggableView snapViewCenterToPoint:self.deletingDraggableView.hiddingCenter edge:[self _destinationEdgeForReleasePointInCurrentState:self.deletingDraggableView.center] completion:^(BOOL finished) {
            if (finished) {
//                [self.deletingDraggableView removeFromSuperview];
            }
        }];
    }
}



-(void)changeDeletingDraggableViewStateWithDraggableView:(OpenDraggableView *)view movePoint:(CGPoint)point{
    CGPoint mPoint=  [view convertPoint:point toView:self.window];
    CGRect rect=CGRectInset(self.deletingDraggableView.frame, -40, -40);
    BOOL isContained= CGRectContainsPoint(rect, mPoint);
    if (isContained && !self.deletingDraggableView.isInDeletableState) {
        self.deletingDraggableView.isInDeletableState=YES;
        [self.deletingDraggableView beginDeletingAnimation];
    }
    else  if (isContained && self.deletingDraggableView.isInDeletableState) {
        NSLog(@"do nothing");
    }
    else {
        self.deletingDraggableView.isInDeletableState=NO;
        [self.deletingDraggableView endDeletingAnimation];
    }
}

#pragma mark - Dragging

- (BOOL)draggableViewCanMove:(OpenDraggableView *)view{
    if (self.draggableViews.count>1
        &&view.canNotDeletable
        &&_state==TBInteractionStateConversation) {
        return NO;
    }
    return YES;
}


- (void)draggableViewHold:(OpenDraggableView *)view
{
    
}

- (void)draggableView:(OpenDraggableView *)view didMoveToPoint:(CGPoint)point
{
    
    switch (_state) {
        case TBInteractionStateConversation:
        {
            if (_presentedNavigationController) {
                [self _dismissPresentedNavigationControllerCompletion:^{
                }];
            }
            break;
        }
        case TBInteractionStateNormal:
        {
            
            NSArray* reversedArray = [[self.draggableViews reverseObjectEnumerator] allObjects];
            for (OpenDraggableView *draggableView in reversedArray) {
                if (draggableView==view) {
                    continue;
                }
                [draggableView snapViewCenterToPoint:view.center edge:CGRectMinXEdge completion:^(BOOL finished) {
                }];
            }
            
            break;
        }
            
        default:
            break;
    }
    
    [self showDeletingDraggableView];
    [self changeDeletingDraggableViewStateWithDraggableView:view movePoint:point];
    
}

-(void)closeAllDraggableView{
    for (OpenDraggableView *subView in [self.draggableViews reverseObjectEnumerator]) {
        [self removeDraggableViewDynamicly:subView];
    }
}



- (void)draggableViewReleased:(OpenDraggableView *)view
{
    [self hideDeletingDraggableView];
    if (self.deletingDraggableView.isInDeletableState) {
        switch (_state) {
            case TBInteractionStateNormal:
                [self closeAllDraggableView];
                break;
                
            case TBInteractionStateConversation:
                [self removeDraggableViewDynamicly:view];
                NSLog(@"delete view %@",view.uniqueIdentifier);
                
                break;
                
            default:
                break;
        }
    }
    
    
    switch (_state) {
        case TBInteractionStateNormal:
            [self _animateViewToEdges:view];
            break;
            
        case TBInteractionStateConversation:{
            [self _animateViewToConversationArea:self.draggableViewInConversation completionBlock:^{
            }];
            [self _presentViewControllerForDraggableView:self.draggableViewInConversation];

        }
            
            break;
            
        default:
            break;
    }
}


- (void)draggableViewTouched:(OpenDraggableView *)view
{
    
    switch (_state) {
        case TBInteractionStateNormal:{
            _state = TBInteractionStateConversation;
            [self _animateViewToConversationArea:view completionBlock:^{
                [self _presentViewControllerForDraggableView:view];
            }];
        }
            break;
        case TBInteractionStateConversation:
        {
            if (self.draggableViewInConversation == view) {
                [self collapseConversation];
            } else{
                [self _switchViewControllerForDraggableView:view];
            }
            break;
        }
            
        default:
            break;
    }
}




#pragma mark - Alignment

- (void)draggableViewNeedsAlignment:(OpenDraggableView *)view
{
    
    if (self.state!=TBInteractionStateConversation) {
        NSLog(@"Align view");
        [self _animateViewToEdges:view];
    }
}


#pragma mark Dragging Helper

- (void)_animateViewToEdges:(OpenDraggableView *)view
{
    CGPoint destinationPoint = [self _destinationPointForReleasePoint:view.center];
    [self _animateView:view toEdgePoint:destinationPoint completionBlock:^{
        
    }];
}


- (void)_animateView:(OpenDraggableView *)view toEdgePoint:(CGPoint)point completionBlock:(void (^)(void))block
{
    [CATransaction begin];
    for (OpenDraggableView *draggableView in self.draggableViews) {
        [draggableView snapViewCenterToPoint:point edge:[self _destinationEdgeForReleasePointInCurrentState:draggableView.center]];
    }
    [CATransaction setCompletionBlock:^{
        
        if (block) {
            block();
        }
    }];
    [CATransaction commit];
    
    [self.edgePointDictionary setObject:[NSValue valueWithCGPoint:point] forKey:OldPoint];
}


- (void)_animateViewToConversationArea:(OpenDraggableView *)view completionBlock:(void (^)(void))block
{
    if (!view) {
        return;
    }
    [self _showDraggableViewsWithCompletionBlock:^{
        if (block) {
            block();
        }
    }];
}



#pragma mark - View Controller Handling

- (CGRect)_navigationControllerFrame
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide([self.window.screen applicationFrame], &slice, &remainder, CGRectGetMaxY([self _conversationArea])-13, CGRectMinYEdge);
    return remainder;
}

- (CGRect)_navigationControllerHiddenFrame
{
    return CGRectMake(CGRectGetMidX([self _conversationArea]), CGRectGetMaxY([self _conversationArea]), 0, 0);
}


-(UINavigationController *)presentedNavigationController{
    if (!_presentedNavigationController) {
        _presentedNavigationController = [[UINavigationController alloc] init];
        
//        _presentedNavigationController = [UINavigationController customizedNavigationController];
        
        _presentedNavigationController.view.layer.cornerRadius = 3;
        _presentedNavigationController.view.layer.masksToBounds = YES;
        _presentedNavigationController.view.layer.anchorPoint = CGPointMake(0.5f, 0);
        _presentedNavigationController.view.frame = [self _navigationControllerFrame];
            _presentedNavigationController.view.transform = CGAffineTransformMakeScale(0, 0);
        _presentedNavigationController.view.clipsToBounds=NO;
        [_presentedNavigationController.view addSubview:self.navArrowImageView];
    }
    return _presentedNavigationController;
    
}


-(void)moveNavArrowImageViewWhileDraggableView:(OpenDraggableView *)draggableView{
    CGPoint point=self.navArrowImageView.center;
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navArrowImageView.center=CGPointMake(draggableView.center.x, point.y);
    } completion:^(BOOL finished){
    }];
    
}


- (void)_switchViewControllerForDraggableView2:(OpenDraggableView *)draggableView
{
    if (!draggableView) {
        return;
    }
    
    if ( _state == TBInteractionStateConversation) {
        
        self.draggableViewInConversation=draggableView;
        
        if (self.draggableViewInConversation
            && ! self.draggableViewInConversation.viewControllerInConversation
            && self.draggableViewInConversation.viewControllerForConversationBlock) {
            self.draggableViewInConversation.viewControllerInConversation = self.draggableViewInConversation.viewControllerForConversationBlock();
        }
        if (![[self.presentedNavigationController.viewControllers lastObject] isEqual:self.draggableViewInConversation.viewControllerInConversation]
            &&self.draggableViewInConversation.viewControllerInConversation) {
            self.presentedNavigationController.viewControllers=@[self.draggableViewInConversation.viewControllerInConversation];
        }
        if (!self.presentedNavigationController.view.superview
            &&self.presentedNavigationController.viewControllers.count>0
            &&self.draggableViews.count>0) {
            [self.window insertSubview:self.presentedNavigationController.view aboveSubview:[self.draggableViews lastObject]];
            [self.window insertSubview:self.presentContainerViewController.view aboveSubview:self.presentedNavigationController.view ];
            self.presentContainerViewController.view.userInteractionEnabled=NO;

            [self _unhidePresentedNavigationControllerCompletion:^{}];
        }
        
        [self moveNavArrowImageViewWhileDraggableView:self.draggableViewInConversation];
        
    }
}

- (void)_switchViewControllerForDraggableView:(OpenDraggableView *)draggableView
{
    if (!draggableView) {
        return;
    }
    
    if (self.draggableViews.count&&[self.delegate respondsToSelector:@selector(draggingCoordinatorWillSwitch:)]) {
        [self.delegate draggingCoordinatorWillSwitch:self];
    }
    
    if ( _state == TBInteractionStateConversation) {
        
        self.draggableViewInConversation=draggableView;
        
        if (self.draggableViewInConversation
            && ! self.draggableViewInConversation.viewControllerInConversation
            && self.draggableViewInConversation.viewControllerForConversationBlock) {
            self.draggableViewInConversation.viewControllerInConversation = self.draggableViewInConversation.viewControllerForConversationBlock();
        }
        if (![self.presentedNavigationController.viewControllers containsObject:self.draggableViewInConversation.viewControllerInConversation]
            &&self.draggableViewInConversation.viewControllerInConversation) {
            
            
            self.presentedNavigationController.viewControllers=@[self.draggableViewInConversation.viewControllerInConversation];
        }
        if (!self.presentedNavigationController.view.superview
            &&self.presentedNavigationController.viewControllers.count>0
            &&self.draggableViews.count>0) {
            [self.window insertSubview:self.presentedNavigationController.view aboveSubview:[self.draggableViews lastObject]];
            [self.window insertSubview:self.presentContainerViewController.view aboveSubview:self.presentedNavigationController.view ];
            self.presentContainerViewController.view.userInteractionEnabled=NO;


            [self _unhidePresentedNavigationControllerCompletion:^{}];
        }
        
        [self moveNavArrowImageViewWhileDraggableView:self.draggableViewInConversation];
        
    }
}


- (void)_presentViewControllerForDraggableView:(OpenDraggableView *)draggableView
{
    [self _switchViewControllerForDraggableView:draggableView];
}


-(UIViewController *)presentContainerViewController{
    if (!_presentContainerViewController) {
        _presentContainerViewController=[[UIViewController alloc] init];
//        _presentContainerViewController.view.backgroundColor=[[UIColor yellowColor] colorWithAlphaComponent:0.5] ;//for debug
        _presentContainerViewController.view.backgroundColor=[UIColor clearColor] ;

        _presentContainerViewController.view.userInteractionEnabled=NO;
    }
    return _presentContainerViewController;
    
}


- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion{
    NSLog(@"the superview is %@",self.presentContainerViewController.view.superview);
    NSLog(@"the windows is %@",self.presentContainerViewController.view.window);
    
    if (!self.presentContainerViewController.view.superview) {
        [self.window insertSubview:self.presentContainerViewController.view aboveSubview:self.presentedNavigationController.view ];
    }
    self.presentContainerViewController.view.userInteractionEnabled=NO;


    _viewControllerPresented = viewControllerToPresent;
    
    
    NSLog(@"the kvo is %@",self.viewControllerPresented.parentViewController);
    
    if ([self.presentContainerViewController respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self.presentContainerViewController presentViewController:_viewControllerPresented animated:YES completion:^{
            if (completion) {
                completion();
            }
        }];
    }
    else
    {
        [self.presentContainerViewController presentModalViewController:_viewControllerPresented animated:YES];
        if (completion) {
            completion();
        }
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"parentViewController" isEqualToString:keyPath] && object == self.viewControllerPresented) {
        
        if (!self.viewControllerPresented.parentViewController){
            NSLog(@"Dismissed");
            [self.viewControllerPresented removeObserver:self forKeyPath:@"parentViewController"];
            [self.presentContainerViewController.view removeFromSuperview];
        }
    }
}


- (void)_dismissPresentedNavigationControllerCompletion:(void(^)())completionBlock
{
    UINavigationController *reference = _presentedNavigationController;
    [self _hidePresentedNavigationControllerCompletion:^{
        [reference.view removeFromSuperview];
        if (completionBlock) {
            completionBlock();
        }

    }];
    _presentedNavigationController = nil;

}


-(CGPoint)defaultPointForRelease{
    return [self _destinationPointForReleasePoint:CGPointMake(self.window.bounds.size.width/2+20, self.window.bounds.size.height-80)];
}

-(void)_collapseConversation{
    _state = TBInteractionStateNormal;
    CGPoint destinationPoint = [self.edgePointDictionary objectForKey:OldPoint]?[[self.edgePointDictionary objectForKey:OldPoint] CGPointValue ]:[self defaultPointForRelease];
    
    [CATransaction begin];
    [self _animateView:nil toEdgePoint:destinationPoint completionBlock:^{
    }];
    [self _dismissPresentedNavigationControllerCompletion:^{
        
    }];
    [CATransaction commit];
}

-(void)collapseConversation{
    [self _readdDraggableViewInView:self.window];
    [self _collapseConversation];
}




- (void)_unhidePresentedNavigationControllerCompletion:(void(^)())completionBlock
{
    CGAffineTransform transformStep1 = CGAffineTransformMakeScale(1.1f, 1.1f);
    CGAffineTransform transformStep2 = CGAffineTransformMakeScale(1, 1);
    
    _backgroundView = [[UIControl alloc] initWithFrame:[self.window bounds]];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5f];
    _backgroundView.alpha = 0.0f;
    [_backgroundView addTarget:self action:@selector(collapseConversation) forControlEvents:UIControlEventTouchUpInside];
    
    [self.window insertSubview:_backgroundView belowSubview:[self.draggableViews objectAtIndex:0]];
    
    if (self.systemVersion>=6.0) {
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _presentedNavigationController.view.layer.affineTransform = transformStep1;
            self.backgroundView.alpha = 1.0f;
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.3f animations:^{
                    _presentedNavigationController.view.layer.affineTransform = transformStep2;
                }];
            }
        }];
    } else{
        _presentedNavigationController.view.layer.affineTransform = transformStep2;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backgroundView.alpha = 1.0f;
        }completion:^(BOOL finished){
        }];
    }
}

- (void)_hidePresentedNavigationControllerCompletion:(void(^)())completionBlock
{
    if (self.systemVersion>=6.0) {
        UIControl *viewToDisplay = _backgroundView;
        [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _presentedNavigationController.view.transform = CGAffineTransformMakeScale(0, 0);
            _presentedNavigationController.view.alpha = 0.0f;
            _backgroundView.alpha = 0.0f;
        } completion:^(BOOL finished){
            if (finished) {
                [viewToDisplay removeFromSuperview];
                if (viewToDisplay == _backgroundView) {
                    _backgroundView = nil;
                }
                completionBlock();
            }
        }];
    } else{
        UIControl *viewToDisplay = _backgroundView;
        [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _presentedNavigationController.view.alpha = 0.0f;
            _backgroundView.alpha = 0.0f;
        } completion:^(BOOL finished){
            if (finished) {
                [viewToDisplay removeFromSuperview];
                if (viewToDisplay == _backgroundView) {
                    _backgroundView = nil;
                }
                completionBlock();
            }
        }];
    }
    
}

- (void)_hidePresentedNavigationControllerCompletion2:(void(^)())completionBlock
{
    UIView *viewToDisplay = _backgroundView;
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];
    animation.duration = 0.3f;
    animation.completion=^(BOOL finished){
        if (finished) {
            [viewToDisplay removeFromSuperview];
            if (viewToDisplay == _backgroundView) {
                _backgroundView = nil;
            }
            completionBlock();
        }
    };
    
    _presentedNavigationController.view.layer.transform = [animation.toValue CATransform3DValue];
    [_presentedNavigationController.view.layer addAnimation:animation forKey:@"transform"];
}
@end
