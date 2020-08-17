//
//  PhotoListViewController.swift
//  Wongnai-IOS-Assignment
//
//  Created by Natthawut Kaeoaubon on 16/8/2563 BE.
//  Copyright © 2563 Natthawut Kaeoaubon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage

class PhotoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var disposeBag = DisposeBag()
    private let photoViewModel = PhotoListViewModel()
    private let refreshControl = UIRefreshControl()
    
    private var lastRow: Int = 0
    private var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create refreshControl and add to tableView
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        
        // register cell
        tableView.register(UINib(nibName: "ImageInsertionCell", bundle: nil), forCellReuseIdentifier: "ImageInsertionCell")
        tableView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellReuseIdentifier: "PhotoCell")
        
        // set separator to full
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        bindTableView()
    }
    
    private func bindTableView() {
        // when publishPhotos publishing data (onNext:)
        photoViewModel.publishPhotos
            .do(onNext: { photos in
                
                // DO: set lastlow from photos.count and end refreshing
                self.lastRow = photos.count - 1
                self.refreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items) {(tableView, row, element) in
                // Bind: data to tableView Item
                
                // calculate to show "ImageInsertionCell" every 5 row
                if (row + 1) % 5 == 0  {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "ImageInsertionCell", for: IndexPath(row: row, section: 0))
                    return cell
                }
                
                // in addition show PhotoCell
                else {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: IndexPath(row: row, section: 0)) as! PhotoCell
                    cell.nameLabel.text = element.name
                    cell.photoDescription.text = element.description
                    cell.votesCountLabel.text = self.numberFormat(from: element.voteCount)
                    cell.photoImage.af.setImage(withURL: URL(string: element.imageUrl)!)
                    
                    return cell
                }
        }
        .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
            // load next page when will Display last row
            if indexPath.row == self.lastRow {
                self.page += 1
                self.photoViewModel.loadPhotos(isInit: false, page: self.page)
            }
        }).disposed(by: disposeBag)
        
        // initial load photos
        photoViewModel.loadPhotos(page: page)
    }
    
    // format int to decimal
    func numberFormat(from value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: value as NSNumber) ?? ""
    }
    
    // event when pull to refresh
    @objc func refresh(_ sender: AnyObject) {
        disposeBag = DisposeBag()
        bindTableView()
    }
}
