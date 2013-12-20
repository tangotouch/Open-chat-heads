![alt tag](https://raw.github.com/tangotouch/Open-chat-heads/master/OpenChatHeads/Example/Image/avator/1.jpg)


@class OpenGroupDraggingCoordinator;
@protocol OpenDraggingCoordinatorDelegate <NSObject>

- (UIViewController *)draggingCoordinator:(OpenGroupDraggingCoordinator *)coordinator viewControllerForDraggableView:(OpenDraggableView *)draggableView;
- (void)draggingCoordinator:(OpenGroupDraggingCoordinator *)coordinator removedLastDraggableView:(OpenDraggableView *)draggableView;
- (NSMutableArray *)draggingCoordinator:(OpenGroupDraggingCoordinator *)coordinator sortDraggableViews:(NSMutableArray *)draggableView;
- (void)draggingCoordinatorWillSwitch:(OpenGroupDraggingCoordinator *)coordinator;

@end


@interface OpenGroupDraggingCoordinator : NSObject <OpenDraggableViewDelegate>

@property (nonatomic) TBGSnappingEdge snappingEdge;
@property (nonatomic, unsafe_unretained) id<OpenDraggingCoordinatorDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *draggableViews;
@property (nonatomic,assign) NSUInteger maxNumberOfAvator;

@property (nonatomic, strong) UINavigationController *presentedNavigationController;
@property (nonatomic, strong) OpenDraggableView *draggableViewInConversation;

- (id)initWithWindow:(UIWindow *)window draggableViewBounds:(CGRect)bounds;
- (BOOL)addDraggableView:(OpenDraggableView *)draggableView;
- (BOOL)addDraggableView:(OpenDraggableView *)draggableView  isSilence:(BOOL)isSilence;
- (BOOL)startConversationForDraggableViewIfNot:(OpenDraggableView *)draggableView;
- (void)removeDraggableViewDynamicly:(OpenDraggableView *)draggableView;
- (void)collapseConversation;
- (void)closeAllDraggableView;
- (void)notifyFullControllerWillClosed;
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;
- (CGPoint)defaultPointForRelease;
-(void)resetState;


@end
