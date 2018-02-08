//
//  ShareBookViewRouter.swift
//  FBook
//
//  Created by Thanh Nguyen Xuan on 9/25/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

protocol ShareBookViewRouter {

    func present(viewControllerToPresent: UIViewController)
    func showPickerView(delegate: ItemPickerPresenterDelegate)
    func showCategoryPicker(delegate: CategoryPickerPresenterDelegate, currentCategory: Category?)
    func showOffice(delegate: ChooseWorkspacePresenterDelegate, currentOffice: Office?)
}

class ShareBookViewRouterImpl {

    fileprivate weak var viewController: ShareBookViewController?

    init(viewController: ShareBookViewController) {
        self.viewController = viewController
    }

}

extension ShareBookViewRouterImpl: ShareBookViewRouter {

    func present(viewControllerToPresent: UIViewController) {
        viewController?.present(viewControllerToPresent, animated: true, completion: nil)
    }

    func showPickerView(delegate: ItemPickerPresenterDelegate) {
        guard let pickerView = UIStoryboard.shareBook.instantiateViewController(withIdentifier: "ItemPickerViewController") as? ItemPickerViewController else {
            return
        }
        pickerView.modalPresentationStyle = .overFullScreen
        pickerView.configurator = ItemPickerConfiguratorImpl(items: [], delegate: delegate)
        viewController?.present(pickerView, animated: true, completion: nil)
    }

    func showCategoryPicker(delegate: CategoryPickerPresenterDelegate, currentCategory: Category?) {
        let categoryPicker = CategoryPickerViewController(nibName: "CategoryPickerViewController", bundle: nil)
        categoryPicker.configurator = CategoryPickerConfiguratorImplementation(delegate: delegate, currentCategory: currentCategory)
        categoryPicker.modalPresentationStyle = .overFullScreen
        viewController?.present(categoryPicker, animated: true, completion: nil)
    }

    func showOffice(delegate: ChooseWorkspacePresenterDelegate, currentOffice: Office?) {
        let office = ChooseWorkspaceViewController(nibName: "ChooseWorkspaceViewController", bundle: nil)
        office.configurator =  ChooseWorkspaceConfiguratorImplementation(delegate: delegate)
        office.modalPresentationStyle = .overFullScreen
        viewController?.present(office, animated: true, completion: nil)
    }
}
