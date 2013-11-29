//
//  TBDeletingDraggableView.m
//  ChatHeads
//
//  Created by 香象 on 28/8/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "OpenDeletingDraggableView.h"
#import "SKBounceAnimation.h"

@implementation OpenDeletingDraggableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)beginDeletingAnimation
{
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.15f, 1.15f, 1)];
    animation.duration = 0.2f;
    
    self.layer.transform = [animation.toValue CATransform3DValue];
    [self.layer addAnimation:animation forKey:nil];
}

- (void)endDeletingAnimation
{
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCATransform3D:self.layer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    animation.duration = 0.2f;
    
    self.layer.transform = [animation.toValue CATransform3DValue];
    [self.layer addAnimation:animation forKey:nil];
}


@end
