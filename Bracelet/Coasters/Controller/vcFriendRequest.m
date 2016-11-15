//
//  vcFriendRequest.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFriendRequest.h"
#import "tvcFriendRequest.h"
#import "RequestFr.h"

@interface vcFriendRequest () <UITableViewDelegate, UITableViewDataSource, tvcFriendRequestDelegate>
{
    FriendRequest *fr_Current;                  // 当前操作的对象
    NSString *fr_Current_id;                    // 记录
    NSInteger countRequest;                     // 请求的数量，  用来阻止下面的删除
    NSIndexPath *currentIndexPath;              // 要删除的行    删除
    NSInteger currentIndex;                     // 执行的索引    接受
    int coutIsEdit;                             // 可删除的行数
}

@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;


@property (strong, nonatomic) UITableView           *tabView;
@property (strong, nonatomic) NSMutableArray        *arrData;

@end

@implementation vcFriendRequest

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"好友申请"];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self initData];
    [self initView];
}

-(void)initLeftButton:(NSString *)imgName text:(NSString *)text
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, (NavBarHeight - 35 ) / 2 + 10, 80, 35)];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.titleLabel.textColor = DWhite;
    [btn setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
    [btn setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
    
    [btn setTitle:kString(text) forState: UIControlStateNormal];
    [btn setImageEdgeInsets: UIEdgeInsetsMake(6, -5, 6, 0)];
    [btn setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -70)];
    [btn setTitleColor:DWhite forState:UIControlStateNormal];
    [btn setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.viewHead addSubview:btn];
    
    self.viewHead.backgroundColor = DidConnectColor;
    self.viewHeadHeight.constant = NavBarHeight;
}


-(void)initData
{
    self.arrData = [NSMutableArray new];
    [self refreshData];
}

-(void)refreshData
{
    [self.arrData removeAllObjects];
    NSArray *arrRequest = [FriendRequest findAllSortedBy:@"isOver" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@", self.userInfo.access, @1] inContext:DBefaultContext];
    coutIsEdit = [[FriendRequest numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @1, @YES] inContext:DBefaultContext] intValue];
    
    
    countRequest = arrRequest.count;
    for (int i = 0; i < countRequest; i++)
    {
        FriendRequest *frst = arrRequest[i];
        RequestFr *fr = [RequestFr new];
        fr.url = frst.user_pic_url;
        fr.name = frst.friend_name;
        fr.isOver = [frst.isOver boolValue];
        fr.model = frst;                            // 请求的才有这个赋值
        [self.arrData addObject:fr];
    }
    
    NSArray *arrFriend = [Friend findAllSortedBy:@"dateTime" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and isRequest == %@", self.userInfo.access, @(YES)] inContext:DBefaultContext];
    for (int i = 0; i < arrFriend.count; i++)
    {
        Friend *f = arrFriend[i];
        RequestFr *fr = [RequestFr new];
        fr.url = f.user_pic_url;
        fr.name = f.user_nick_name;
        fr.isOver = YES;
        [self.arrData addObject:fr];
    }
}


-(void)initView
{
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    [self initTable];
}

-(void)initTable
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight-NavBarHeight) style:UITableViewStyleGrouped];
    self.tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(100), 55);
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.scrollEnabled = YES;
    self.tabView.backgroundColor = DLightGrayBlackGroundColor;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcFriendRequest" bundle:nil] forCellReuseIdentifier:@"tvcFriendRequest"];
    self.tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view;
    });
    [self.view addSubview:self.tabView];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriendRequest *cell = [tvcFriendRequest cellWithTableView:tableView];
    RequestFr *model = self.arrData[indexPath.row];
    cell.model = model;
    cell.delegateA = self;
    if (indexPath.row < coutIsEdit)
    {
        MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
        cell.rightButtons = @[btnDelete];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        DDWeak(self)
        btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
        {
            [weakself gotoDelete:indexPath];
            return NO;
        };
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@,%@", @(indexPath.row),@(coutIsEdit));
    if (indexPath.row < coutIsEdit)
        return YES;
    else
        return NO;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        RequestFr *rf = self.arrData[indexPath.row];
//        fr_Current =  (FriendRequest *)rf.model;
//        currentIndexPath = indexPath;          // 要删除的行
//        fr_Current_id = fr_Current.friend_id;
//        [self deleteTableData];
//        [self updateShip:NO];
//    }
//}

-(void)gotoDelete:(NSIndexPath *)indexPath
{
    RequestFr *rf = self.arrData[indexPath.row];
    fr_Current =  (FriendRequest *)rf.model;
    currentIndexPath = indexPath;          // 要删除的行
    fr_Current_id = fr_Current.friend_id;
    [self deleteTableData];
    [self updateShip:NO];
}

//修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return kString(@"删除");
//}

#pragma mark tvcFriendRequestDelegate
-(void)accept:(RequestFr *)rf
{
    fr_Current = (FriendRequest *)rf.model;
    
    for (int i = 0; i < self.arrData.count; i++)
    {
        RequestFr *rf = self.arrData[i];
        if (rf.model && [rf.model isEqual:fr_Current])
        {
            currentIndex = i;
            break;
        }
    }
    
    [self deleteTableData];
    [self updateShip:YES];
    [self refreshData];
    [self.tabView reloadData];
}

// 确认删除这一行
-(void)deleteTableData
{
    if (currentIndexPath)
    {
        RequestFr *rf = self.arrData[currentIndexPath.row];
        [self.arrData removeObject:rf];
        FriendRequest *fr = rf.model;
        
        [FriendRequest MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@", fr.access, fr.friend_id] inContext:DBefaultContext];
        
        DBSave;
        
        [self.tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tabView endUpdates];
        [self.tabView reloadData];
        currentIndexPath = nil;
    }
    else
    {
        // 接受了好友   //  这里没有重新拉去 好友列表  TODO
        //NSArray *arrFr1 = [FriendRequest findAll];
        RequestFr *fr = self.arrData[currentIndex];
        FriendRequest *f = (FriendRequest *)fr.model;
        f.isOver = @(YES);
        DBSave;
        
        //NSArray *arrFr = [FriendRequest findAll];
        [self refreshData];
        [self.tabView reloadData];
    }
}

-(void)updateShip:(BOOL)isAccept
{
    RequestCheckAfter(
          [net updateFriendship:self.userInfo.access
                      friend_id:(fr_Current.friend_id ? fr_Current.friend_id : fr_Current_id )
                    ship_status:isAccept? @"1": @"2"];,
          [self dataSuccessBack_updateFriendship:dic isAccept:isAccept];); 
}

-(void)dataSuccessBack_updateFriendship:(NSDictionary *)dic isAccept:(BOOL)isAccept
{
    if (CheckIsOK)
    {
        NSLog(@"删除成功");
        [self.tabView reloadData];
        if (isAccept) {
            LMBShow(@"已接受")
        }else{
            LMBShow(@"已拒绝")
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
