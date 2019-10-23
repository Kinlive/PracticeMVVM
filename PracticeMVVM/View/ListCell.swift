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
        viewModel?.clearOnReuse()
        
    }
    
    func setup(viewModel: ListCellViewModel) {
        self.viewModel = viewModel
        
        viewModel.events.onTitleChanged.binding { [weak self] value in
            DispatchQueue.main.async {
                self?.titleLabel.text = value
            }
        }
        
        viewModel.events.onDescriptionChanged.binding { [weak self] value in
            DispatchQueue.main.async {
                 self?.descriptionLabel.text = value
            }
        }
        
        viewModel.events.onImageDownloaded.binding { [weak self] value in
            DispatchQueue.main.async {
                self?.albumImageView.image = value
            }
        }
       
    }

}
