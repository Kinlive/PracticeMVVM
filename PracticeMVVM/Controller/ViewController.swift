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
    
    let viewModel = ViewControllerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initView()
        bindViewModel()
    }
    
    func initView() {
        searchBar.delegate = self
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        
    }
    
    func bindViewModel() {
        viewModel.onRequestEnd = { [weak self] in
            DispatchQueue.main.async {
                self?.listTableView.reloadData()
            }
        }
        
    }

}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchText = searchBar.text ?? ""
        searchBar.endEditing(true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else { return UITableViewCell() }
        
        let listCellViewModel = viewModel.listCellViewModels[indexPath.row]
        cell.setup(viewModel: listCellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listCellViewModel = viewModel.listCellViewModels[indexPath.row]
        
        convienceAlert(alert: "Tapped: \(listCellViewModel.title)",
                alertMessage: "music: \(listCellViewModel.description)",
                     actions: ["確認"],
                  completion: nil, actionCompletion: nil)
    }
    
}
