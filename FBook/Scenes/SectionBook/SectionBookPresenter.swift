//
//  SectionBookPresenter.swift
//  FBook
//
//  Created by Ban Nguyen Ngoc on 9/13/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import RxSwift
import RxCocoa

protocol SectionBookView: class {
    weak var collectionView: UICollectionView! { get }
    weak var categoryButton: UIButton! { get }
    weak var sortButton: UIButton! { get }
    weak var orderButton: UIButton! { get }
    func showLoadBooksError(_ message: String)
    func displayLoading(isLoading: Bool)
}

protocol SectionBookPresenter: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
}

class SectionBookPresenterImplementation: NSObject {

    fileprivate let router: SectionBookRouter?
    fileprivate weak var view: SectionBookView?
    fileprivate let sectionBook: SectionBook
    fileprivate var listItems = ListItems<Book>()
    fileprivate var isLoading = false
    fileprivate var refreshControl = UIRefreshControl()
    fileprivate var category = Variable<Category?>(nil)
    fileprivate var sort = Variable<SortType>(.countView)
    fileprivate var orderBy: OrderBy = .desc {
        didSet {
            if orderBy == .asc {
                view?.orderButton.setImage(#imageLiteral(resourceName: "ic_up"), for: .normal)
                view?.orderButton.setTitle(orderBy.rawValue + " ", for: .normal)
            } else {
                view?.orderButton.setImage(#imageLiteral(resourceName: "ic_down"), for: .normal)
                view?.orderButton.setTitle(orderBy.rawValue, for: .normal)
            }
        }
    }
    fileprivate let disposeBag = DisposeBag()

    init(router: SectionBookRouter?, view: SectionBookView?, sectionBook: SectionBook) {
        self.router = router
        self.view = view
        self.sectionBook = sectionBook
        super.init()
        configureCollectionView()
        getBooks()
        guard let categoryButton = view?.categoryButton, let sortButton = view?.sortButton, let orderButton = view?.orderButton else {
            return
        }
        // Observable when button tapped
        categoryButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.router?.showCategoryPicker(delegate: weakSelf, currentCategory: weakSelf.category.value)
        }).disposed(by: disposeBag)

        sortButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.router?.showSortBook(delegate: weakSelf, currentSort: weakSelf.sort.value)
        }).disposed(by: disposeBag)

        orderButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.orderBy.invert()
            weakSelf.refreshing()
        }).disposed(by: disposeBag)

        // Observable when variable change value
        category.asObservable().map { category in
            return category?.name ?? "All"
        }.bind(to: categoryButton.rx.title()).disposed(by: disposeBag)

        sort.asObservable().map { sort in
            return sort.getTitle()
        }.bind(to: sortButton.rx.title()).disposed(by: disposeBag)
    }

    fileprivate func configureCollectionView() {
        view?.collectionView.backgroundView = refreshControl
        view?.collectionView.registerNibCell(type: BookCollectionViewCell.self)
        view?.collectionView.delegate = self
        view?.collectionView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshing), for: .valueChanged)
    }

    @objc func refreshing() {
        getBooks()
    }
    private func getBooks(page: Int = 1) {
        if category.value != nil {
            getListBook(page: page)
        } else {
            getBookInSection(page: page)
        }
    }
    fileprivate func getBookInSection(page: Int = 1) {
        weak var weakSelf = self
        if isLoading {
            return
        }
        isLoading = true
        BookProvider.getBooks(inSection: sectionBook, page: page, officeId: Office.currentId)
            .on(failed: { error in
                weakSelf?.view?.showLoadBooksError(error.message)
            }, completed: {
            }, disposed: {
                weakSelf?.isLoading = false
                weakSelf?.refreshControl.endRefreshing()
                weakSelf?.view?.displayLoading(isLoading: false)
            }, value: { listItems in
                if page != 1 {
                    weakSelf?.listItems.append(listItems)
                } else {
                    weakSelf?.listItems = listItems
                }
                weakSelf?.view?.collectionView.reloadData()
            }).start()
    }
    fileprivate func getListBook(page: Int = 1) {
        weak var weakSelf = self
        if isLoading {
            return
        }
        isLoading = true
        let param = FilterSortBookParams()
        param.categories = category.value
        param.sort = sort.value
        param.section = sectionBook.key
        param.order = orderBy
        BookProvider.getBooksFilterSort( params: param, page: page, officeId: Office.currentId)
            .on(failed: { error in
                weakSelf?.view?.showLoadBooksError(error.message)
            }, completed: {
            }, disposed: {
                weakSelf?.isLoading = false
                weakSelf?.refreshControl.endRefreshing()
                weakSelf?.view?.displayLoading(isLoading: false)
            }, value: { listItems in
                if page != 1 {
                    weakSelf?.listItems.append(listItems)
                } else {
                    weakSelf?.listItems = listItems
                }
                weakSelf?.view?.collectionView.reloadData()
        }).start()
    }
}

extension SectionBookPresenterImplementation: SectionBookPresenter {
}

extension SectionBookPresenterImplementation: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return BookCollectionViewCell.fitSizeItem(withSize: collectionView.frame.size)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        router?.showBookDetail(book: listItems.data[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.row == listItems.total - 1, let nextPage = listItems.nextPage {
            getBooks(page: nextPage)
        }
    }

}

extension SectionBookPresenterImplementation: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
                        -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableNibCell(type: BookCollectionViewCell.self, atIndex: indexPath),
                let book = listItems.data[safe: indexPath.row] else {
            return UICollectionViewCell()
        }
        cell.displayBook(book: book)
        return cell
    }

}

extension SectionBookPresenterImplementation: CategoryPickerPresenterDelegate {

    func categoryPickerPresenter(didSelect category: Category?) {
        self.category.value = category
        view?.displayLoading(isLoading: true)
        refreshing()
    }

}

extension SectionBookPresenterImplementation: SortBookPresenterDelegate {

    func sortBookPresenter(didSelect sort: SortType) {
        self.sort.value = sort
        view?.displayLoading(isLoading: true)
        refreshing()
    }
}
