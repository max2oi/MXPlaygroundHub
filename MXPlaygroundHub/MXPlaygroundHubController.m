//
// Created by max2oi on 2018/6/27.
// Copyright (c) 2018 max2oi. All rights reserved.
//

#import <objc/runtime.h>
#import "MXPlaygroundHubController.h"
#import "MXPlaygroundProtocol.h"

@interface MXHubModel : NSObject
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *detailDescription;
@property (nonatomic, copy)NSString *type;
@property (nonatomic, assign)Class vcClass;
+ (instancetype)modelWithClass:(Class)cls;
- (UIViewController *)spawnController;
@end

@interface MXPlaygroundHubViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *typeTableView;
@property (nonatomic, strong)UITableView *itemTableView;
@property (nonatomic, strong)NSArray<MXHubModel *> *hubModels;
@end

static NSString *const kLastVCNameKey = @"kLastVCClassKey";

@implementation MXPlaygroundHubViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    /// 获取模型
    NSMutableArray<MXHubModel *> *hubModels = [NSMutableArray array];
    int numberOfClasses = objc_getClassList(NULL, 0);
    Class *classList = (__unsafe_unretained Class *)malloc(numberOfClasses * sizeof(Class));
    numberOfClasses = objc_getClassList(classList, numberOfClasses);
    for (int idx = 0; idx < numberOfClasses; idx++) {
        Class cls = classList[idx];
        if (class_conformsToProtocol(cls, @protocol(MXPlaygroundProtocol))) {
            [hubModels addObject:[MXHubModel modelWithClass:cls]];
        }
    }
    free(classList);
    /// 先type后title进行字典排序
    NSSortDescriptor *typeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    self.hubModels = [[hubModels copy] sortedArrayUsingDescriptors:@[typeSortDescriptor, titleSortDescriptor]];

    self.typeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.typeTableView.delegate = self;
    self.typeTableView.dataSource = self;
    [self.view addSubview:self.typeTableView];

    self.itemTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.itemTableView.delegate = self;
    self.itemTableView.dataSource = self;
    [self.view addSubview:self.itemTableView];

    self.view.backgroundColor = UIColor.lightGrayColor;
    self.title = @"HUB";

    /// 载入上一个最后进入的VC, 便于调试
    NSString *lastVCName = [NSUserDefaults.standardUserDefaults objectForKey:kLastVCNameKey];
    if (lastVCName.length) {
        Class cls = NSClassFromString(lastVCName);
        if (cls) {
            MXHubModel *model = [MXHubModel modelWithClass:cls];
            [self.navigationController pushViewController:[model spawnController] animated:NO];
        }
    }

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat typeTableViewWidth = 100;
    CGFloat spacing = 2;
    CGFloat tableViewY;
    if (@available(iOS 11.0, *)) {
        tableViewY = self.view.safeAreaInsets.top;
    } else {
        tableViewY = 64;
    }
    CGFloat height = CGRectGetHeight(self.view.frame) - tableViewY;
    CGFloat itemTableViewWidth = CGRectGetWidth(self.view.frame) - spacing - typeTableViewWidth;
    self.typeTableView.frame = CGRectMake(0, tableViewY, typeTableViewWidth, height);
    self.itemTableView.frame = CGRectMake(CGRectGetMaxX(self.typeTableView.frame) + spacing, tableViewY, itemTableViewWidth, height);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.itemTableView) {
        return self.maxmxHub_Types.count;
    }
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.itemTableView) {
        return self.maxmxHub_Types[section];
    }
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.typeTableView) {
        return self.maxmxHub_Types.count;
    }
    else if (tableView == self.itemTableView) {
        return [self maxHub_modelsForTypeIndex:section].count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.typeTableView) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell"] ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TypeCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.text = self.maxmxHub_Types[indexPath.row];
        return cell;
    }
    else if (tableView == self.itemTableView) {
        MXHubModel *model = [self itemModelForIndexPath:indexPath];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"] ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ItemCell"];
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.detailDescription;
        return cell;
    }

    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.typeTableView) {
        [self.itemTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (tableView == self.itemTableView) {
        MXHubModel *model = [self itemModelForIndexPath:indexPath];
        [NSUserDefaults.standardUserDefaults setObject:NSStringFromClass(model.vcClass) forKey:kLastVCNameKey];     /// 记住最后进入的VC
        [self.navigationController pushViewController:[model spawnController] animated:YES];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.itemTableView) {
        UITableViewRowAction *classInfoAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSStringFromClass([self itemModelForIndexPath:indexPath].vcClass) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [tableView endEditing:YES];
        }];
        return @[classInfoAction];
    }
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - filters

- (NSArray<NSString *> *)maxmxHub_Types {
    static NSArray<NSString *> *types;
    if (types == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (MXHubModel *model in self.hubModels) {
            dict[model.type] = @"";
        }
        types = [dict.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];       /// type数组也进行字典排序
    }
    return types;
}

- (NSArray<MXHubModel *> *)maxHub_modelsForType:(NSString *)type {
    static NSMutableDictionary<NSString *, NSArray<MXHubModel *> *> *modelsForType;
    if (modelsForType == nil) {
        modelsForType = [NSMutableDictionary dictionary];

        NSArray<NSString *> *types = self.maxmxHub_Types;
        for (NSString *_type in types) {
            NSMutableArray<MXHubModel *> *models = [NSMutableArray array];
            for (MXHubModel *model in self.hubModels) {
                if ([model.type isEqualToString:_type]) {
                    [models addObject:model];
                }
            }
            modelsForType[_type] = [models copy];
        }

    }

    return modelsForType[type];
}

- (NSArray<MXHubModel *> *)maxHub_modelsForTypeIndex:(NSInteger)typeIndex {
    NSArray<NSString *> *types = self.maxmxHub_Types;
    NSString *type = types[typeIndex];
    return [self maxHub_modelsForType:type];
}

- (MXHubModel *)itemModelForIndexPath:(NSIndexPath *)indexPath {
    NSArray<MXHubModel *> *modelsForType = [self maxHub_modelsForTypeIndex:indexPath.section];
    MXHubModel *model = modelsForType[indexPath.row];
    return model;
}


@end

@implementation MXHubModel
+ (instancetype)modelWithClass:(Class)cls {
    MXHubModel *model = [[MXHubModel alloc] initWithClass:cls];

    if ([cls respondsToSelector:@selector(mxHub_Title)]) {
        model.title = [cls performSelector:@selector(mxHub_Title)];
    }
    if ([cls respondsToSelector:@selector(mxHub_Description)]) {
        model.detailDescription = [cls performSelector:@selector(mxHub_Description)];
    }
    if ([cls respondsToSelector:@selector(mxHub_Type)]) {
        model.type = [cls performSelector:@selector(mxHub_Type)];
    }

    return model;
}

- (instancetype)initWithClass:(Class)cls {
    self = [super init];
    if (self) {
        NSParameterAssert([cls isSubclassOfClass:UIViewController.class]);
        self.vcClass = cls;
        self.title = NSStringFromClass(self.vcClass);
        self.detailDescription = @"no further detail";
        self.type = @"no type";
    }
    return self;
}

- (UIViewController *)spawnController {
    UIViewController *controller = (UIViewController *)[[self.vcClass alloc] init];
    controller.title = self.title;
    return controller;
}

@end

@implementation MXPlaygroundHubController
- (instancetype)init {
    self = [super initWithRootViewController:[[MXPlaygroundHubViewController alloc] init]];
    if (self) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:47/255.0f green:184/255.0f blue:253/255.0f alpha:1.0]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];;
    }
    return self;
}
@end