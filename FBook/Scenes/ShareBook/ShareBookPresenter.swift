//
//  ShareBookPresenter.swift
//  FBook
//
//  Created by Thanh Nguyen Xuan on 9/25/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import Foundation
import Photos
import QBImagePickerController
import ReactiveSwift
import RxSwift
import RxCocoa

enum ItemType {

    case category
    case publishDate
    case office

}

protocol ShareBookView: class {

    weak var categoryButton: UIButton! { get }
    weak var publishDataButton: UIButton! { get }
    weak var officeButton: UIButton! { get }
    weak var categoryTextField: CustomTextField! { get }
    weak var publishDateTextField: CustomTextField! { get }
    weak var officeTextField: CustomTextField! { get }
    func updateUI()
    func displayChooseImageSourceDialog()
    func updateBackgroundInternalButton()
    func updateBackgroundGoogleButton()
}

protocol ShareBookPresenter {

    func configure(collectionView: UICollectionView, height: NSLayoutConstraint)
    func configure(textFields: UITextField...)
    func openCamera()
    func openPhotoLibrary()
    func displaySelectItems(type: ItemType)
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
    func didSelectedInternalBookButton()
    func didSelectedGoogleBookButton()
    func didCreateBookButton(title: String, description: String?, author: String, publishDate: Date?, categoryID: Int?, officeID: Int?, medias: [Medias])
}

class ShareBookPresenterImpl: NSObject {

    private(set) var router: ShareBookViewRouter?
    fileprivate weak var view: ShareBookView?
    fileprivate var category = Variable<Category?>(nil)
    fileprivate let disposeBag = DisposeBag()
    fileprivate var publishDate = Variable<Date?>(nil)
    fileprivate var office = Variable<Office?>(nil)
    
    var photos = [UIImage]()
    let numberOfCells: CGFloat = 2.0
    let photoRatio: CGFloat = 3.0 / 4.0
    var cellWidth: CGFloat = 0.0
    var cellHeight: CGFloat = 0.0
    var categoryItemType = ItemType.category
    var publishDateItemType = ItemType.publishDate
    var officeItemType = ItemType.office

    init(view: ShareBookView, router: ShareBookViewRouter) {
        self.view = view
        self.router = router
        super.init()
        guard let categoryTextField = view.categoryTextField, let categoryButton = view.categoryButton else {
            return
        }
        guard let publishDateTextField = view.publishDateTextField, let publishDateButton = view.publishDataButton else {
            return
        }
        guard let officeTextField = view.officeTextField, let officeButton = view.officeButton else {
            return
        }

        categoryButton.rx.tap.asObservable().subscribe(onNext: { [weak self] in guard let weakSelf = self else {
                return
            }
            weakSelf.router?.showCategoryPicker(delegate: weakSelf, currentCategory: weakSelf.category.value)
        }).disposed(by: disposeBag)

        publishDateButton.rx.tap.asObservable().subscribe(onNext: { [weak self] in guard let weakSelf = self else {
                return
            }
            weakSelf.router?.showPickerView(delegate: weakSelf)
        }).disposed(by: disposeBag)

        officeButton.rx.tap.asObservable().subscribe(onNext: { [weak self] in guard let weakSelf = self else {
                return
            }
            weakSelf.router?.showOffice(delegate: weakSelf, currentOffice: weakSelf.office.value)
        }).disposed(by: disposeBag)

        //asObservable
        category.asObservable().map { category in
            return category?.name
            }.bind(to: categoryTextField.rx.text).disposed(by: disposeBag)

        publishDate.asObservable().map { date in
            return date?.toSeverStringkDateFormatYMD()
        }.bind(to: publishDateTextField.rx.text).disposed(by: disposeBag)

        office.asObservable().map { (office) in
            return office?.name
        }.bind(to: officeTextField.rx.text).disposed(by: disposeBag)
    }

    fileprivate func displayChooseImageSourceDialog() {
        view?.displayChooseImageSourceDialog()
    }

}

// MARK: - ShareBookPresenter

extension ShareBookPresenterImpl: ShareBookPresenter {

    func configure(collectionView: UICollectionView, height: NSLayoutConstraint) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerNibCell(type: PhotoCollectionViewCell.self)
        cellWidth = (UIScreen.main.bounds.width - 16.0) / numberOfCells
        cellHeight = (cellWidth - 16.0) / photoRatio
        height.constant = cellHeight
    }

    func configure(textFields: UITextField...) {
        textFields.forEach({ $0.delegate = self })
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            router?.present(viewControllerToPresent: imagePickerController)
        } else {
            // TODO: Display camera error message
        }
    }

    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = QBImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsMultipleSelection = true
            imagePickerController.mediaType = .image
            router?.present(viewControllerToPresent: imagePickerController)
        } else {
            // TODO: Display photo library error message
        }
    }

    func displaySelectItems(type: ItemType) {
        switch type {
        case .category:
            break
        case .office:
            break
        case .publishDate:
            break
        }
    }

    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    func didSelectedInternalBookButton() {
        view?.updateBackgroundInternalButton()
        //
    }

    func didSelectedGoogleBookButton() {
        view?.updateBackgroundGoogleButton()
        //
    }
    
    func didCreateBookButton(title: String, description: String?, author: String, publishDate: Date?, categoryID: Int?, officeID: Int?, medias: [Medias]) {
        
    }
}

// MARK: - UICollectionViewDataSource

extension ShareBookPresenterImpl: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableNibCell(type: PhotoCollectionViewCell.self, atIndex: indexPath)
              else {
            return UICollectionViewCell()
        }
        let photo = photos[safe: indexPath.row]
        cell.updateUI(photo: photo)
        cell.addPhoto = { [weak self] in
            self?.displayChooseImageSourceDialog()
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ShareBookPresenterImpl: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }

}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension ShareBookPresenterImpl: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let photo = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true) {
            self.photos.append(photo)
            self.view?.updateUI()
        }
    }

}

// MARK: - QBImagePickerControllerDelegate

extension ShareBookPresenterImpl: QBImagePickerControllerDelegate {

    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }

    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!,
                                  didFinishPickingAssets assets: [Any]!) {
        let imageManager = PHImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        assets.forEach({
            guard let asset = $0 as? PHAsset else {
                return
            }
            let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit,
                options: options) { [weak self] (image, _) in
                    guard let image = image else {
                        return
                    }
                    self?.photos.append(image)
                }
            })
        imagePickerController.dismiss(animated: true) {
            self.view?.updateUI()
        }
    }

}

// MARK: - UITextFieldDelegate

extension ShareBookPresenterImpl: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension ShareBookPresenterImpl: CategoryPickerPresenterDelegate {
    func categoryPickerPresenter(didSelect category: Category?) {
        self.category.value = category
    }
}

extension ShareBookPresenterImpl: ChooseWorkspacePresenterDelegate {
    func didSelect(office: Office?) {
        self.office.value = office
    }
}

extension ShareBookPresenterImpl: ItemPickerPresenterDelegate {
    func didSelect(didSelect picker: Date?) {
        self.publishDate.value = picker
    }
}
