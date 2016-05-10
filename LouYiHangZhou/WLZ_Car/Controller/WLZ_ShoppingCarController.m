//
//  WLZ_ShoppingCarController.m
//  WLZ_ShoppingCart
//
//  Created by lijiarui on 15/12/14.
//  Copyright © 2015年 lijiarui. All rights reserved.
//




//   MVVM (降低耦合) KVO(一处计算总价钱) 键盘处理(精确到每个cell) 代码适配(手动代码适配，无第三方) ，还有全选,侧滑操作等操作
#import "PayViewController.h"
#import "WLZ_ShoppingCarController.h"
#import "BYSHttpTool.h"
#import "HttpParameters.h"
#import "HomeViewController.h"
#import "UIViewController+StoryboardFrom.h"
#import "LogonVViewController.h"
@interface WLZ_ShoppingCarController () <UITableViewDataSource,UITableViewDelegate,WLZ_ShoppingCarCellDelegate,WLZ_ShoppingCartEndViewDelegate>
{
    BOOL isLogoin;
}


@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *carDataArrList;
@property(nonatomic,strong)UIToolbar *toolbar;
@property (nonatomic , strong) UIBarButtonItem *previousBarButton;
@property (nonatomic , strong) UIImageView *islogoinImageView;
@property (nonatomic , strong) UIImageView *isnilImageView;

@property(nonatomic,assign)BOOL isEdit;
@property(nonatomic,strong)WLZ_ShoppingCartEndView *endView;
@property(nonatomic,strong) WLZ_ShopViewModel *vm;

@end

@implementation WLZ_ShoppingCarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _vm = [[WLZ_ShopViewModel alloc]init];
    
    


    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
   

    
    
    //获取数据
  }







//本来想着kvo写在 Controller里面 但是想尝试不同的方式 试试在viewModel 里面 ，感觉还是在Controller 里面更 好点

- (void)numPrice
{
    NSArray *lists =   [_endView.Lab.text componentsSeparatedByString:@"￥"];
    float num = 0.00;
    if (self.carDataArrList != nil && self.carDataArrList.count != 0) {
        NSArray *list = [self.carDataArrList objectAtIndex:0];
        for (int i=0; i<list.count; i++) {
            WLZ_ShoppIngCarModel *model = [list objectAtIndex:i];
            float sale = [model.sale_price floatValue];
            NSInteger count = [model.qty floatValue];
            
            num = count*sale + num;
            NSLog(@"count=====%ld  ======%.2f",count,num);
            
            
            
            
        }
        _endView.Lab.text = [NSString stringWithFormat:@"%@￥%.2f",lists[0],num];


    }

    }


-(WLZ_ShoppingCartEndView *)endView
{
    if (!_endView) {
        _endView = [[WLZ_ShoppingCartEndView alloc]initWithFrame:CGRectMake(0, APPScreenHeight-[WLZ_ShoppingCartEndView getViewHeight]-49, APPScreenWidth, [WLZ_ShoppingCartEndView getViewHeight])];
        _endView.delegate=self;
        
        
    }
    return _endView;
}




- (void)clickRightBT:(UIButton *)bt
{
    if(bt.tag==19)
    {
        //删除
        for (int i = 0; i<_carDataArrList.count; i++) {
            NSMutableArray *arry = [_carDataArrList objectAtIndex:i];
            for (int j=0 ; j<arry.count-1; j++) {
                WLZ_ShoppIngCarModel *model = [ arry objectAtIndex:j];
                if (model.isSelect==YES) {
                    [arry removeObjectAtIndex:j];
                    continue;
                }
            }
            if (arry.count<=1) {
                [_carDataArrList removeObjectAtIndex:i];
            }
        }
        [_tableView reloadData];
    }
    else if (bt.tag==18)
    {
        PayViewController *pay = [[PayViewController alloc]init];
        pay.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pay animated:YES];
        
    }
    
    
    
}

//
//- (NSMutableArray *)carDataArrList
//{
//    if (!_carDataArrList) {
//        _carDataArrList = [NSMutableArray array];
//    }
//    return _carDataArrList;
//}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, APPScreenWidth, APPScreenHeight-[WLZ_ShoppingCartEndView getViewHeight]) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.userInteractionEnabled=YES;
        _tableView.dataSource = self;
        _tableView.scrollsToTop=YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorFromHexRGB:@"e2e2e2"];
    }
    return _tableView;
}

- (void)endViewHidden
{
    if (_carDataArrList.count==0) {
        self.endView.hidden=YES;
    }
    else
    {
        self.endView.hidden=NO;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if (self.carDataArrList.count == 0) {
        [self.tableView removeFromSuperview];
        [self.endView removeFromSuperview];

        if (isLogoin) {
            
            _isnilImageView= [[UIImageView alloc]initWithFrame:self.view.frame];
            UIImage *image = [UIImage imageNamed:@"img_cart_null"];
            _isnilImageView.image = image;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTabbaritem)];
            _isnilImageView.userInteractionEnabled = YES;
            [_isnilImageView addGestureRecognizer:tap];
            [self.view addSubview:_isnilImageView];
            

        }else
        {
            self.isnilImageView.hidden = YES ;

        }
        
    }  else
    {
        [self.view addSubview:self.tableView];
        [self.view addSubview:self.endView];

    }
    NSLog(@"%ld",_carDataArrList.count);
        return self.carDataArrList.count;
    
}
-(void)changeTabbaritem
{
    self.tabBarController.selectedIndex = 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WLZ_ShoppingCarCell getHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *shoppingCaridentis = @"WLZ_ShoppingCarCells";
    WLZ_ShoppingCarCell *cell = [tableView dequeueReusableCellWithIdentifier:shoppingCaridentis];
    if (!cell) {
        cell = [[WLZ_ShoppingCarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shoppingCaridentis tableView:tableView];
        cell.delegate=self;
    }
    if (self.carDataArrList.count>0) {
        NSArray *list = [self.carDataArrList objectAtIndex:indexPath.section];
        cell.row = indexPath.row+1;
        [cell setModel:[list objectAtIndex:indexPath.row]];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        if (list.count-2 !=indexPath.row) {
            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(45, [WLZ_ShoppingCarCell getHeight]-0.5, APPScreenWidth-45, 0.5)];
            line.backgroundColor=[UIColor colorFromHexRGB:@"e2e2e2"];
            [cell addSubview:line];
        }
    }
  
    return cell;
}
- (void)singleClick:(WLZ_ShoppIngCarModel *)models row:(NSInteger)row
{
    [_vm pitchOn:_carDataArrList];
    if (models.type==1) {
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(models.type==2)
    {
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        NSMutableArray *list = [_carDataArrList objectAtIndex:1];
        
        
        
        WLZ_ShoppIngCarModel *model = [ list objectAtIndex:indexPath.row];
        model.isSelect=NO;
        [list removeObjectAtIndex:indexPath.row];
        
        if (list.count==1) {
            
            
            [_carDataArrList removeObjectAtIndex:indexPath.section];
            
        }
        
        [_tableView reloadData];
        
    }
}



-(void)dealloc
{
    _tableView = nil;
    _tableView.dataSource=nil;
    _tableView.delegate=nil;
    self.vm = nil;
    self.endView = nil;
    self.carDataArrList = nil;
    NSLog(@"Controller释放了。。。。。");
}


- (void)keyboardWillShow:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
    
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = rect.origin.y;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    NSArray *subviews = [self.view subviews];
    for (UIView *sub in subviews) {
        CGFloat maxY = CGRectGetMaxY(sub.frame);
        if ([sub isKindOfClass:[UITableView class]]) {

                sub.frame = CGRectMake(0, 0, sub.frame.size.width, APPScreenHeight-_toolbar.frame.size.height-rect.size.height);
                sub.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, sub.frame.size.height/2);

        }else{
            if (maxY > y - 2) {
                sub.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, sub.center.y - maxY + y );
            }
        }
    }
    [UIView commitAnimations];
}

- (void)keyboardShow:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    NSArray *subviews = [self.view subviews];
    for (UIView *sub in subviews) {
        if (sub.center.y < CGRectGetHeight(self.view.frame)/2.0) {
            sub.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, CGRectGetHeight(self.view.frame)/2.0);
        }
    }
      _toolbar.frame=CGRectMake(0, APPScreenHeight, APPScreenWidth, _toolbar.frame.size.height);
    _endView.frame = CGRectMake(0, self.view.frame.size.height-_endView.frame.size.height, APPScreenWidth, _endView.frame.size.height);

    self.tableView.frame=CGRectMake(0, 0, self.tableView.frame.size.width, APPScreenHeight-[WLZ_ShoppingCartEndView getViewHeight]);
    [UIView commitAnimations];
}

- (void)keyboardHide:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"购物车";
    [super viewWillAppear:YES];
    isLogoin = [USER_DEFAULT objectForKey:@"user_token"];

    if (isLogoin) {
        _carDataArrList = [NSMutableArray array];
        NSLog(@"%@",_carDataArrList);
        
        __weak typeof (WLZ_ShoppingCarController) *waks = self;
        __weak typeof (NSMutableArray)* carDataArrList =self.carDataArrList;
        __weak typeof (UITableView ) *tableView = self.tableView;
        [_vm getShopData:^(NSArray *commonArry) {
            [carDataArrList addObject:commonArry];
            NSLog(@"%@ ------------",carDataArrList);
            [tableView reloadData];
            [waks numPrice];
        } priceBlock:^{
            
            [waks numPrice];
        }];
        
        
        [self.tableView reloadData];
        [self.islogoinImageView removeFromSuperview];
        
        

    }else
    {
        _islogoinImageView= [[UIImageView alloc]initWithFrame:self.view.frame];
        _islogoinImageView.image = [UIImage imageNamed:@"img_no_login"];
        UITapGestureRecognizer *singeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loginEvent)];
        _islogoinImageView.userInteractionEnabled = YES;

        [_islogoinImageView addGestureRecognizer:singeTap];
        [_isnilImageView removeFromSuperview];
        [self.view addSubview:_islogoinImageView];
    }
    
   
    
    
}
-(void)loginEvent
{
    
    [self.navigationController pushViewController:[LogonVViewController instanceFromStoryboard] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBarHidden = YES;
    
}

@end
