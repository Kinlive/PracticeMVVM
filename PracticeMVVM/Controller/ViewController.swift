//
//  ViewController.swift
//  PracticeMVVM
//
//  Created by Thinkpower on 2019/10/18.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listTableView: UITableView!
    
    let service = RequestCommunicator<DownloadMusic>()
    var musicHandlers: [MusicHandler] = []
    let downloadImageQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func initView() {
        searchBar.delegate = self
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        
    }
    
    func prepareRequest(with name: String) {
        service.request(type: .searchMusic(media: "music", entity: "song", term: name)) { [weak self] (result) in
            switch result {
            case .success(let response):
                if let musicHandelr = MusicHandler.updateSearchResults(response.data, section: 0) {
                    self?.musicHandlers.append(contentsOf: musicHandelr)
                    self?.listTableView.reloadData()
                }
                
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func getImage(string: String, at indexPath: IndexPath, cell: UITableViewCell) {
        guard let url = URL(string: string) else { return }
        downloadImageQueue.addOperation {
           do {
               let data = try Data(contentsOf: url)
               let image = UIImage(data: data)
               DispatchQueue.main.async {
                    guard let listCell = cell as? ListCell else { return }
                    listCell.albumImageView.image = image
                    listCell.setNeedsLayout()
               }
               
           } catch let error {
               printLog(logs: [error.localizedDescription], title: "Get Image Error-")
           }
        }
    }

}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        prepareRequest(with: searchBar.text ?? "")
        searchBar.endEditing(true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicHandlers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else { return UITableViewCell() }
        
        let handler = musicHandlers[indexPath.row]
        cell.titleLabel.text = handler.collectionName
        cell.descriptionLabel.text = handler.name
        getImage(string: handler.imageUrl, at: indexPath, cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let handler = musicHandlers[indexPath.row]
        
        convienceAlert(alert: "Tapped: \(handler.artist)",
                alertMessage: "music: \(handler.name)",
                     actions: ["確認"],
                  completion: nil, actionCompletion: nil)
    }
    
}
