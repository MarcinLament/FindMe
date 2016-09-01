//
//  AvatarGenerator.swift
//  FindMe
//
//  Created by Marcin Lament on 31/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import AvatarImageView

public class AvatarGenerator{
    
    struct Config: AvatarImageViewConfiguration { var shape: Shape = .Circle }
    
    static func getAvatar(name: String, imageView: AvatarImageView) -> AvatarImageView{
        imageView.configuration = Config()
        imageView.dataSource = AvatarData(name: name)
        return imageView
    }
}

struct AvatarData: AvatarImageViewDataSource {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}