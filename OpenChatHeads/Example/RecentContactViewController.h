//
//  RecentContactViewController.h
//  OpenChatHeads
//
//  Created by 香象 on 29/11/13.
//  Copyright (c) 2013 香象. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentContactViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *datas;
@end
