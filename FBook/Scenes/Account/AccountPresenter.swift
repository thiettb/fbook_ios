//
//  AccountPresenter.swift
//  FBook
//
//  Created by tran.xuan.diep on 9/22/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import UIKit
import SwiftHEXColors
import RxSwift
import RxCocoa

protocol AccountView: class {
    func refreshAccount()
    func showLoadAccountError(message: String)
}

protocol AccountPresenter {

    func configure(tableView: UITableView)
    func fetchUserInfo()
    func fetchCategories(_ tableView: UITableView)
    func fetchFollowers()
    func fetchFollowingUsers()
    func updateFollow()
    func handleLoadCategoriesSuccess(_ categories: [Category], _ tableView: UITableView)
    func handleLoadUsersSuccess(_ users: [User])
    func handleLoadUserInfoSuccess()

}

class AccountPresenterImplementation: NSObject, AccountPresenter {

    fileprivate weak var view: AccountView?
    fileprivate var router: AccountRouter?
    fileprivate var user: User
    fileprivate var listCategories = [Category]()
    fileprivate var listUsers = [User]()
    fileprivate var listFavoriteCategories = [Category]()
    fileprivate var currentTab = Tab.profile

    init(view: AccountView?, router: AccountRouter?, user: User) {
        self.view = view
        self.router = router
        self.user = user
    }

    func configure(tableView: UITableView) {
        tableView.registerNibCell(type: HeaderTableViewCell.self)
        tableView.registerNibCell(type: ProfilCell.self)
        tableView.registerNibCell(type: TabTableViewCell.self)
        tableView.registerNibCell(type: CategoryTableViewCell.self)
        tableView.registerNibCell(type: FollowerTableViewCell.self)
        tableView.registerNibCell(type: FollowingTableViewCell.self)
        tableView.registerNibCell(type: ProfileTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func fetchUserInfo() {
        guard let currentUser = User.currentUser else {
            return
        }
        weak var weakSelf = self
        if currentUser.id != user.id {
            AlertHelper.showLoading()
            UsersProvider.getOtherUserProfile(userId: user.id).on(failed: { error in
                Utility.shared.showMessage(message: error.message, completion: nil)
            }, disposed: {
                AlertHelper.hideLoading()
            }, value: { userInfo in
                weakSelf?.user = userInfo
                weakSelf?.handleLoadUserInfoSuccess()
            }).start()
        } else {
            weakSelf?.handleLoadUserInfoSuccess()
        }
    }

    func fetchCategories(_ tableView: UITableView) {
        fetchFavoriteCategories()
        AlertHelper.showLoading()
        CategoryProvider.getCategories().on(failed: { error in
            Utility.shared.showMessage(message: error.message, completion: nil)
        }, disposed: {
            AlertHelper.hideLoading()
        }, value: { categories in
            self.handleLoadCategoriesSuccess(categories, tableView)
        }).start()
    }

    func fetchFavoriteCategories() {
        listFavoriteCategories.removeAll()
        guard let currentUser = User.currentUser else {
            return
        }
        if currentUser.id != user.id {
            UsersProvider.getFavoriteCategoriesOfCurrentUser(userId: user.id).on(failed: { error in
                Utility.shared.showMessage(message: error.message, completion: nil)
            }, disposed: {
            }, value: { categories in
                self.listFavoriteCategories.append(contentsOf: categories)
            }).start()
        } else {
            listFavoriteCategories.append(contentsOf: currentUser.favoriteCategories)
        }
    }

    func fetchFollowers() {
        AlertHelper.showLoading()
        UsersProvider.getFollowersOfUser(userId: user.id).on(failed: { error in
            Utility.shared.showMessage(message: error.message, completion: nil)
        }, disposed: {
            AlertHelper.hideLoading()
        }, value: { users in
            self.handleLoadUsersSuccess(users)
        }).start()
    }

    func fetchFollowingUsers() {
        AlertHelper.showLoading()
        UsersProvider.getFollowingOfUser(userId: user.id).on(failed: { error in
            Utility.shared.showMessage(message: error.message, completion: nil)
        }, disposed: {
            AlertHelper.hideLoading()
        }, value: { users in
            self.handleLoadUsersSuccess(users)
        }).start()
    }

    func updateFollow() {
        AlertHelper.showLoading()
        UsersProvider.followUser(userId: user.id).on(failed: { error in
            Utility.shared.showMessage(message: error.message, completion: nil)
        }, disposed: {
            AlertHelper.hideLoading()
        }, value: { status in
            Utility.shared.showMessage(message: "\(status)", completion: nil)
        }).start()
    }

    func handleLoadCategoriesSuccess(_ categories: [Category], _ tableView: UITableView) {
        listCategories.removeAll()
        listCategories.append(contentsOf: categories)
        self.view?.refreshAccount()
        for category in listFavoriteCategories {
            if let index = categories.index(where: {$0.id == category.id}),
                let cell = tableView.cellForRow(at: [2, index]) as? CategoryTableViewCell {
                cell.checkBoxButton.isSelected = true
            }
        }
    }

    func handleLoadUsersSuccess(_ users: [User]) {
        listUsers.removeAll()
        listUsers.append(contentsOf: users)
        self.view?.refreshAccount()
    }

    func handleLoadUserInfoSuccess() {
        self.view?.refreshAccount()
    }

    func editButtonTapped(_ sender: Any) {
//      TODO edit profile
    }

    func saveButtonTapped(_ sender: Any) {
//      TODO save favorite categories
    }

}

extension AccountPresenterImplementation: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension AccountPresenterImplementation: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 270
        case 1:
            return 350
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableNibCell(type: HeaderTableViewCell.self) else {
                return UITableViewCell()
            }
            cell.setBackgroundCell()
            checkStateFollowButton(cell)
            cell.displayUser(user)
            cell.handleButtonFollowTapped = { _ in
                self.handleButtonFollowTapped(cell: cell)
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableNibCell(type: ProfilCell.self) else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }

    fileprivate func loadProfileTab(tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableNibCell(type: ProfileTableViewCell.self) else {
            return UITableViewCell()
        }
        cell.displayProfile(user)
        return cell
    }

    fileprivate func loadCategoriesTab(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableNibCell(type: CategoryTableViewCell.self) else {
            return UITableViewCell()
        }
        cell.updateCell(categoryName: listCategories[indexPath.row].name)
        return cell
    }

    fileprivate func loadFollowersTab(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableNibCell(type: FollowerTableViewCell.self) else {
            return UITableViewCell()
        }
        cell.updateCell(listUsers[indexPath.row])
        return cell
    }

    fileprivate func loadFollowingTab(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableNibCell(type: FollowingTableViewCell.self) else {
            return UITableViewCell()
        }
        cell.updateCell(listUsers[indexPath.row])
        return cell
    }

    fileprivate func handleButtonFollowTapped(cell: HeaderTableViewCell) {
        if cell.followButton.isSelected {
            cell.followButtonEnable()
        } else {
            cell.unfollowButtonEnable()
        }
        updateFollow()
    }

    fileprivate func checkStateFollowButton(_ cell: HeaderTableViewCell) {
        if User.currentUser?.id != user.id {
            cell.unfollowButtonEnable()
        } else {
            cell.followButton.isHidden = true
        }
    }
}

extension AccountPresenterImplementation: ProfileCellDelegate {
    func didSelectPersonal() {
        router?.showPersonal()
    }
    
    func didSelectShare() {
        router?.showShare()
    }
}
