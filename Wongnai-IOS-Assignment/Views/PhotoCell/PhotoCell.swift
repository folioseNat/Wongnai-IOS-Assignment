//
//  PhotoCell.swift
//  Wongnai-IOS-Assignment
//
//  Created by Natthawut Kaeoaubon on 16/8/2563 BE.
//  Copyright © 2563 Natthawut Kaeoaubon. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var votesCountLabel: UILabel!
    @IBOutlet weak var photoDescription: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        photoImage.layer.cornerRadius = 4
    }
    
    override func prepareForReuse() {
        photoImage.image = nil
        nameLabel.text = ""
        votesCountLabel.text = ""
        photoDescription.text = ""
    }
    
}
