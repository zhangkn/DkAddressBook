//
//  ViewController.m
//  DkAddressBook
//
//  Created by devzkn on 17/10/2016.
//  Copyright © 2016 DevKevin. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupABAddressBookGetAuthorization];
    
    
}

- (BOOL)setupABAddressBookGetAuthorization{
    
    //判断是否需要授权
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized ) {
        return YES;
    }
     __block BOOL isgranted;
    ABAddressBookRef addressBook  = ABAddressBookCreateWithOptions(nil, nil);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            NSLog(@"授权访问通讯录成功");
        }else{
            NSLog(@"授权访问通讯录失败");
        }
        isgranted = granted;
    });
    return isgranted;
}

/** 通讯录基本访问*/
- (void)copyAbaddressInfo{
    //判断是否需要授权
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized ) {
        return ;
    }
    //创建通讯录对象
    ABAddressBookRef addressBook  = ABAddressBookCreateWithOptions(nil, nil);
    //获取联系人信息
     CFArrayRef allPeole = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    //打印联系人信息
    for (int i =0; i<CFArrayGetCount(allPeole); i++) {
//        [self pintPeople:CFArrayGetValueAtIndex(allPeole, i)];
        [self updatePeople:CFArrayGetValueAtIndex(allPeole, i) addressBook:addressBook];//更新
    }
    
}
/** 打印联系人信息*/
- (void)pintPeople:(ABRecordRef)people {
    // 获取简单属性
    CFStringRef  personfirstName =   ABRecordCopyValue(people, kABPersonFirstNameProperty);
    NSLog(@"%@",personfirstName);
    //获取多重属性：电话号码、电子邮件等；
    [self pintPeopleMobils:ABRecordCopyValue(people, kABPersonPhoneProperty)];
    //获取组合属性：地址等
    
}
/** 打印多重数据 */
- (void)pintPeopleMobils:(ABMultiValueRef) multiValue{
    for (int i =0 ; i< ABMultiValueGetCount(multiValue); i++) {
        CFStringRef mobil= ABMultiValueCopyValueAtIndex(multiValue, i);//从所有电话获取具体号码
        CFStringRef mobilLabel= ABMultiValueCopyLabelAtIndex(multiValue, i);//从所有电话获取具体号码的类型
        NSLog(@"mobilLabel :%@ mobil:%@",mobilLabel,mobil);
    }
}


#pragma mark - 修改通讯录信息
- (void)updatePeople:(ABRecordRef)people addressBook:(ABAddressBookRef)addressBook {
    //修改姓名kABPersonFirstNameProperty
    CFStringRef  personfirstName = @"kevin";
    ABRecordSetValue(people, kABPersonFirstNameProperty, personfirstName, nil);
    ABAddressBookSave(addressBook, nil);
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self copyAbaddressInfo];
    [self createAbaddressInfo];
}

#pragma mark - 新增联系人
- (void)createAbaddressInfo{
    ABRecordRef people = ABPersonCreate();
    ABRecordSetValue(people, kABPersonFirstNameProperty, @"zhang", nil);
    ABRecordSetValue(people, kABPersonLastNameProperty, @"kevin", nil);
    //创建电话属性
    ABMultiValueRef mobil = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(mobil, @"18874054877", kABPersonPhoneMainLabel, nil);
    ABMultiValueAddValueAndLabel(mobil, @"18874054872", kABPersonPhoneHomeFAXLabel, nil);
    ABMultiValueAddValueAndLabel(mobil, @"18874054879", kABPersonPhoneIPhoneLabel, nil);
    //设置电话信息到联系人
    ABRecordSetValue(people, kABPersonPhoneProperty, mobil, nil);

    //获取通讯录
    ABAddressBookRef addressBook  = ABAddressBookCreateWithOptions(nil, nil);
    
    //添加联系人
    ABAddressBookAddRecord(addressBook, people, nil);
    ABAddressBookSave(addressBook, nil);
    
}


@end

