//
//  ViewController.swift
//  ScorpCaseStudy
//
//  Created by Kursat on 6.08.2021.
//

import UIKit

class ViewController: UIViewController {
    let refreshControl = UIRefreshControl()
    let tableView = UITableView(frame: .zero)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let loadingCell = LoadingTableViewCell(style: .default, reuseIdentifier: "LoadingCell")
    var peopleData = [Person]()
    var nextItem: String?
    var isFetching: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.allowsSelection = false
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "LoadingCell")
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tryFetching()
        
    }
    
    func fetchData(next: String? = nil, success: @escaping (FetchResponse) -> Void, failure: @escaping (FetchError) -> Void) {
        if isFetching { return }
        isFetching = true
        DataSource.fetch(next: next) { (fetchResponse, fetchError) in
            self.isFetching = false
            guard let fetchResponse = fetchResponse else {
                failure(fetchError!)
                return
            }
            success(fetchResponse)
        }
    }
    
    func tryFetching() {
        retry(next: nextItem, times: 3, task: fetchData, success: {
            print("succeeded")
        }, failure: { (error) in
            print(error.errorDescription)
        })
    }
    
    func retry(next: String? = nil, times: Int, task: @escaping (String?, @escaping(FetchResponse) -> Void, @escaping(FetchError) -> Void) -> Void, success: @escaping () -> Void, failure: @escaping (FetchError) -> Void ) {
        task(next, { response in
            self.peopleData += response.people
            self.peopleData = self.peopleData.uniqued()
            self.nextItem = response.next
            self.tableView.reloadData()
        }, { error in
            if times > 0 {
                print(error.errorDescription)
                self.retry(times: times-1, task: task, success: success, failure: failure)
            } else {
                failure(error)
            }
        })
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        peopleData.removeAll()
        nextItem = nil
        tryFetching()
        sender.endRefreshing()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if peopleData.count == 0 {
            tableView.backgroundView = EmptyTableViewBackground(frame: tableView.frame)
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        if nextItem != nil {
            return peopleData.count + 1
        }
        return peopleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if nextItem != nil && peopleData.count == indexPath.row {
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingTableViewCell
            loadingCell.activityIndicatorView.startAnimating()
            return loadingCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if indexPath.row < peopleData.count {
            cell.prepare(person: peopleData[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is LoadingTableViewCell {
            (cell as! LoadingTableViewCell).activityIndicatorView.startAnimating()
            if !isFetching {
                tryFetching()
            }
        }
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
