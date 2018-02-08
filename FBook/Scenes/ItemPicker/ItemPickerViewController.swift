//
//  ItemPickerViewController.swift
//  FBook
//
//  Created by Thanh Nguyen Xuan on 9/26/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class ItemPickerViewController: UIViewController {

    @IBOutlet fileprivate weak var backgroundButton: UIButton!
    @IBOutlet fileprivate weak var pickerView: UIView!
    @IBOutlet fileprivate weak var itemsPicker: UIPickerView!
    @IBOutlet fileprivate weak var datePicker: UIDatePicker!

    var presenter: ItemPickerPresenter?
    var configurator: ItemPickerConfigurator?

    fileprivate let alphaTransparent: CGFloat = 0.7

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator?.configure(viewController: self)
        presenter?.configure(pickerView: itemsPicker)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidePickerView(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPickerView()
    }

    fileprivate func hidePickerView(animated: Bool = true, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: animated ? kDefaultAnimationDuration : 0.0, animations: {
            let viewHeight = self.pickerView.frame.height
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: viewHeight)
            self.backgroundButton.alpha = 0.0
        }, completion: { _ in
            completion?()
        })
    }

    fileprivate func showPickerView() {
        UIView.animate(withDuration: kDefaultAnimationDuration, animations: {
            self.pickerView.transform = CGAffineTransform.identity
            self.backgroundButton.alpha = self.alphaTransparent
        }, completion: nil)
    }

    // MARK: - IBAction

    @IBAction func backgroundViewTapped(_ sender: Any) {
        hidePickerView {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        presenter?.didSelectDate(date: datePicker.date)
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - ItemPickerView

extension ItemPickerViewController: ItemPickerView {

}

