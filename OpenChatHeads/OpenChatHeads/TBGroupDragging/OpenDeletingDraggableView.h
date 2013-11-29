//
//  TBDeletingDraggableView.h
//  ChatHeads
//
//  Created by 香象 on 28/8/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "OpenDraggableView.h"

@interface OpenDeletingDraggableView : OpenDraggableView
@property (assign, nonatomic) BOOL isVisiable;
@property (assign, nonatomic) BOOL isInDeletableState;
@property (assign, nonatomic) CGPoint hiddingCenter;
@property (assign, nonatomic) CGPoint showingCenter;
- (void)beginDeletingAnimation;
- (void)endDeletingAnimation;

@end
