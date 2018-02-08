//
//  AccountRouter.swift
//  FBook
//
//  Created by tran.xuan.diep on 9/22/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import UIKit

protocol AccountRouter {
    func showUserDetail(_ user: User)
    func showPersonal()
    func showShare()
}

class AccountRouterImplementation: AccountRouter {

    fileprivate weak var viewController: AccountViewController?

    init(viewController: AccountViewController) {
        self.viewController = viewController
    }

    func showUserDetail(_ user: User) {
        guard let accountViewController = UIStoryboard.account.instantiateInitialViewController()
            as? AccountViewController else {
                return
        }
        accountViewController.configurator = AccountConfiguratorImplementation(user: user)
        accountViewController.configurator?.configure(viewController: accountViewController)
        viewController?.navigationController?.pushViewController(accountViewController, animated: true)
    }

    func showPersonal() {
        let personalViewController = PersonalViewController()
        personalViewController.hidesBottomBarWhenPushed = true
        self.viewController?.navigationController?.pushViewController(personalViewController, animated: true)
    }
    
    func showShare(){
        guard let shareBook = UIStoryboard.shareBook.instantiateViewController(withIdentifier: "ShareBookViewController") as? ShareBookViewController else {
            return
        }
        shareBook.hidesBottomBarWhenPushed = true
        self.viewController?.navigationController?.pushViewController(shareBook, animated: true)
    }
}
