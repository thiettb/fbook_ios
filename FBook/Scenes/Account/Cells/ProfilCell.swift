//
//  ProfilCell.swift
//  FBook
//
//  Created by ThietTB on 2/5/18.
//  Copyright © 2018 Framgia. All rights reserved.
//

import UIKit

protocol ProfileCellDelegate: NSObjectProtocol {
    func didSelectPersonal()
    func didSelectShare()
}

class ProfilCell: UITableViewCell {
    weak var delegate: ProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func pressPersonal(_ sender: UIButton) {
        self.delegate?.didSelectPersonal()
    }

    @IBAction func pressApproved(_ sender: UIButton) {
    }
    @IBAction func pressShare(_ sender: UIButton) {
        self.delegate?.didSelectShare()
    }

    @IBAction func pressSetting(_ sender: UIButton) {

    }

    @IBAction func pressLogOut(_ sender: UIButton) {

    }
}
