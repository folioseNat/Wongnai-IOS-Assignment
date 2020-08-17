//
//  PhotoListViewModel.swift
//  Wongnai-IOS-Assignment
//
//  Created by Natthawut Kaeoaubon on 16/8/2563 BE.
//  Copyright © 2563 Natthawut Kaeoaubon. All rights reserved.
//


import RxSwift
import RxCocoa
import Alamofire

class PhotoListViewModel {
    let publishPhotos = BehaviorRelay<[Photo]>(value: [])
    
    func loadPhotos(isInit: Bool = true, page: Int) {
        AF.request("https://api.500px.com/v1/photos?feature=popular&page=\(page)")
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                switch response.result {
                case let .success(result):
                    if let data = result as? NSDictionary, let photo = data["photos"] as? [NSDictionary] {
                        
                        let photoArray = photo.map { (result) -> Photo in
                            return self.mapJsonToPhoto(json: result)
                        }
                        if isInit {
                            self.publishPhotos.accept(photoArray)
                        } else {
                            var newPhotos = self.publishPhotos.value
                            newPhotos.append(contentsOf: photoArray)
                            self.publishPhotos.accept(newPhotos)
                        }
                    }
                    
                case let .failure(error):
                    print(error.localizedDescription)
                }
        }
    }
    
    func mapJsonToPhoto(json: NSDictionary) -> Photo {
        if let imageUrl = json["image_url"] as? [String],
            let name = json["name"] as? String,
            let description = json["description"] as? String,
            let voteCount = json["votes_count"] as? Int  {
            
            return Photo(imageUrl: imageUrl.first ?? "", name: name, description: description, voteCount: voteCount)
            
        } else {
            return Photo(imageUrl: "", name: "", description: "", voteCount: 0)
        }
    }
    
    
}
