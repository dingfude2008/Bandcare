//
//  vcAbout.m
//  Coasters
//
//  Created by 丁付德 on 15/9/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcAbout.h"
#import "vcFeedback.h"
#import "vcUseHelp.h"

@interface vcAbout ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFirstHeight;
@property (weak, nonatomic) IBOutlet UIView *viewFirst;

@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UIView *viewSecond;

@property (strong, nonatomic) UITableView *tabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblVersionTop;
@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;



@end

@implementation vcAbout

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"关于"];
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

//-(void)initLeftButton:(NSString *)imgName text:(NSString *)text
//{
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(17, (NavBarHeight - 35 ) / 2 + 10, 80, 35)];
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    btn.titleLabel.font = [UIFont systemFontOfSize:15];
//    btn.titleLabel.textColor = DWhite;
//    [btn setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
//    [btn setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
//    
//    [btn setTitle:kString(text) forState: UIControlStateNormal];
//    [btn setImageEdgeInsets: UIEdgeInsetsMake(6, -5, 6, 0)];
//    [btn setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -70)];
//    [btn setTitleColor:DWhite forState:UIControlStateNormal];
//    [btn setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
//    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    [self.viewHead addSubview:btn];
//    
//    self.viewHead.backgroundColor = DidConnectColor;
//    self.viewHeadHeight.constant = NavBarHeight;
//}

-(void)initData
{
    
}

-(void)initTableView
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,  Bigger(RealHeight(88), 50) * 3)];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(88), 50); // 50;
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.scrollEnabled = NO;                        // 不让滚动， 但接收事件
    self.tabView.userInteractionEnabled = YES;
    [self.viewSecond addSubview:self.tabView];
}

-(void)initView
{
    self.viewMainHeight.constant = ScreenHeight;
    self.viewFirst.backgroundColor = DidConnectColor;//_1;
    self.viewFirstHeight.constant = ScreenHeight * 0.4;
    self.imvCenter.constant = self.lblVersionTop.constant = RealHeight(40);
    
    self.lblVersion.text = [NSString stringWithFormat:@"%@ %@", [DFD getIOSName], [DFD getIOSVersion]];
    self.lblCompany.text = kString(@"深圳市鑫亿科技开发有限公司版权所有");
    
    [self initTableView];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 3;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CMainCell = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = kString(@"意见反馈");
            break;
        case 1:
            cell.textLabel.text = kString(@"使用帮助");
            break;
        case 2:
            cell.textLabel.text = kString(@"赏个好评");
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"about_to_feedback" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"about_to_userhelp" sender:nil];
            break;
        case 2:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", APPID]]];
        }
            break;
            
        default:
            break;
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
