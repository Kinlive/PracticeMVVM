//
//  ListCell.swift
//  PracticeMVVM
//
//  Created by Thinkpower on 2019/10/18.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {

   
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var viewModel: ListCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumImageView.image = nil
        self.viewModel?.onImageDownloaded = nil
        
    }
    
    func setup(viewModel: ListCellViewModel) {
        self.viewModel = viewModel
        
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        
        self.viewModel?.onImageDownloaded = { [weak self] image in
            DispatchQueue.main.async {
                self?.albumImageView.image = image
            }
        }
        self.viewModel?.getImage()
    }

}
