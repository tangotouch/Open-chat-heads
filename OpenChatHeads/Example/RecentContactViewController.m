//
//  RecentContactViewController.m
//  OpenChatHeads
//
//  Created by 香象 on 29/11/13.
//  Copyright (c) 2013 香象. All rights reserved.
//

#import "RecentContactViewController.h"
#import "ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers.h"
#import "DraggableViewComponentInit.h"
#import "OpenDraggableView+TBAvatar.h"
#import "AvatorTableViewCell.h"

@interface RecentContactViewController ()

@end

@implementation RecentContactViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


-(UITableView *)tableView{
    if (!_tableView) {
        _tableView= [[UITableView alloc]initWithFrame:self.view.frame];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


-(NSMutableArray *)datas{
    if (!_datas) {
        _datas=[@[@"1.jpg",
                  @"2.jpg",
                  @"3.jpg",
                  @"4.jpg",
                  @"5.jpg",
                  @"6.jpg",
                  @"7.jpg",
                  @"8.png",
                  @"9.png",
                  @"10.png",
                  @"11.jpg",
                  @"12.jpg",
                  @"13.jpg",
                  @"14.jpg",
                  @"15.jpg",
                  @"16.jpg",
                  @"17.jpg",
                  @"18.jpg",
                  @"19.jpg",
                  @"20.jpg",
                  @"21.jpg",
                  @"22.jpg",
                  @"23.jpg",
                  @"24.jpg",
                 ] mutableCopy];
    }
    return _datas;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AvatorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[AvatorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *user=[[ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers alloc]
                                                               init];
    
    NSString *nick= [self.datas objectAtIndex:indexPath.row];
    user.nick=nick;
    user.headPic=nick;
    
    [cell.draggableView configWithUser:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers *user=[[ComTaobaoMtopIhomeGetBindUsersResponseDataBindUsers alloc]
                                                               init];
    
    NSString *nick= [self.datas objectAtIndex:indexPath.row];
    user.nick=nick;
    user.headPic=nick;
    [[DraggableViewComponentInit sharedInstance] chatWithUser:user];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
