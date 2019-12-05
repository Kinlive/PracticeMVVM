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
    
    lazy var viewModel: ViewControllerViewModel = {
        return ViewControllerViewModel(delegate: self)
    }()
    
    var searchTextChanged: Observable<String> = Observable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initView()
    }
    
    func initView() {
        searchBar.delegate = self
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        
    }

}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchTextChanged.onNext(searchBar.text)
        self.searchBar.bindText?.onNext(searchBar.text)
        searchBar.endEditing(true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs?.listCellViewModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else { return UITableViewCell() }
        
        if let listCellViewModel = viewModel.outputs?.listCellViewModels[indexPath.row] {
            cell.setup(viewModel: listCellViewModel)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listCellViewModel = viewModel.outputs?.listCellViewModels[indexPath.row] else { return }
        
        convienceAlert(alert: "Tapped: \(listCellViewModel.events.onTitleChanged.value ?? "")",
            alertMessage: "music: \(listCellViewModel.events.onDescriptionChanged.value ?? "")",
                     actions: ["確認"],
                  completion: nil, actionCompletion: nil)
    }
    
}

// MARK: - ViewModel delegate
extension ViewController: ViewModelDelegate {
    func binding() -> ViewControllerViewModel.Events {
        // prepare bind observable
        let requestEnd = Observable<Void>().binding { [weak self] _ in
            DispatchQueue.main.async {
                self?.listTableView.reloadData()
            }
        }
        
        let requestFail = Observable<Error>().binding { [weak self] (error) in
            DispatchQueue.main.async {
                self?.convienceAlert(alert: "Search error", alertMessage: error?.localizedDescription, actions: ["確認"], completion: nil, actionCompletion: nil)
            }
        }
        
        return ViewControllerViewModel.Events(onSearchMusics: searchBar.bindText ?? Observable("bind fail"),//searchTextChanged,
                                                onRequestEnd: requestEnd,
                                               onRequestFail: requestFail)
    }
}
