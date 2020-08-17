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
    let photos = BehaviorRelay<[Photo]>(value: [])
    
    // func load Photos using Alamofire
    func loadPhotos(isInit: Bool = true, page: Int) {
        AF.request("https://api.500px.com/v1/photos?feature=popular&page=\(page)")
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                print("Loaded")
                switch response.result {
                case let .success(result):
                    if let data = result as? NSDictionary, let photo = data["photos"] as? [NSDictionary] {
                        
                        // map Json to Photo
                        let photoArray = photo.map { (result) -> Photo in
                            return self.mapJsonToPhoto(json: result)
                        }
                        
                        // check for add next page to Photos or not
                        if isInit {
                            self.photos.accept(photoArray)
                        } else {
                            var newPhotos = self.photos.value
                            newPhotos.append(contentsOf: photoArray)
                            self.photos.accept(newPhotos)
                        }
                    }
                    
                case .failure:
                    // reload Photo if fail
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                        print("Reload")
                        self.loadPhotos(isInit: isInit, page: page)
                    }
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
