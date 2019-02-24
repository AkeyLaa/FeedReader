//
//  TableViewController.swift
//  FeedReader
//
//  Created by Sergey on 21/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class TableViewController: UITableViewController, UISearchResultsUpdating{
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var articles = [ArticlesEntity]()
    
    var searchResults:[ArticlesEntity] = []
    
    let isoformatter = ISO8601DateFormatter.init()
    
    var dateFormatter = DateFormatter();
    
    var timer = Timer()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refresh(_:)) , for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData() //Load data from CoreData
        
        getJsonData() //Reload from network and save in CoreData
        
        createRefreshConrol() //Set refresh ability
        
        createSearchControl() //Set search ability
        
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true) //Set timer to reload data from network
        
        dateFormatter.dateFormat = "dd MMM HH:mm" //Format of date
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(deleteData))
        
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    

    func getFormattedDate(string: String) -> Date?{
        isoformatter.formatOptions.insert(.withFractionalSeconds)
        let date = isoformatter.date(from: string)
        return date
    }
    
    func createSearchControl(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func createRefreshConrol(){
        if #available(iOS 10.0, *){
            tableView.refreshControl = refresher
        }else{
            tableView.addSubview(refresher)
        }
    }
    
    func filterControl(for searchText: String) {
        searchResults = articles.filter({ (article) -> Bool in
        if let name = article.title {
            let isMatch = name.localizedCaseInsensitiveContains(searchText)
            return isMatch
        }
        return false
    })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterControl(for: searchText)
            tableView.reloadData()
        }
    }
    
    @objc private func refresh(_ sender: Any ) {
        self.getJsonData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let svc = SFSafariViewController(url: articles[indexPath.row].url ?? URL(string: "https://russian.rt.com/news")!)
        present(svc, animated: true, completion: nil)
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return searchResults.count
        } else {
            return articles.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenSize.height/6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let article = (searchController.isActive) ? searchResults[indexPath.row]
            : articles[indexPath.row]
        cell.titleLabel.text = article.title
        cell.dataLabel.text = article.text
        cell.dateLabel.text = dateFormatter.string(from: article.date!)
        cell.thumbImage.image = UIImage(data: article.image ?? Data(count: 0))
        return cell
    }
    
    func getJsonData() {
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?sources=rt&apiKey=92d87d28683f48bb8da8af8cdb63e50d") else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let _ = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                if let articlesFromJson = json["articles"] as? [[String: AnyObject]] {
                    for articleFromJson in articlesFromJson{
                        if let headline  = articleFromJson["title"] as? String, let _ = articleFromJson["author"] as? String, let desc = articleFromJson["description"] as? String, let urlStr = articleFromJson["url"] as? String, let urlToImage = articleFromJson["urlToImage"] as? String, let dataImage = try? Data(contentsOf: URL(string: urlToImage)!), let url = URL(string: urlStr), let datePub = articleFromJson["publishedAt"] as? String {
                            let dateP = self.getFormattedDate(string: datePub)
                            DispatchQueue.main.async {
                                self.saveData(title: headline, text: desc, image: dataImage, url: url, date: dateP ?? Date())
                            }
                        }
                    }
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
            DispatchQueue.main.async {
                self.loadData()
            }
        }
        task.resume()
    }
    
    func saveData(title: String, text: String, image: Data, url: URL, date: Date) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ArticlesEntity", in: context)
        let newArticle = NSManagedObject(entity: entity!, insertInto: context) as! ArticlesEntity
        
        newArticle.setValue(title, forKey: "title")
        newArticle.setValue(text, forKey: "text")
        newArticle.setValue(image, forKey: "image")
        newArticle.setValue(url, forKey: "url")
        newArticle.setValue(date, forKey: "date")

        if context.hasChanges{
            do {
                try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
    }
    
    func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate  else {return}
        let context = appDelegate.persistentContainer.viewContext
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticlesEntity")
        request.sortDescriptors = [sortDescriptor]
        request.returnsObjectsAsFaults = false
        
        do {
            if let result = try? context.fetch(request) as! [ArticlesEntity]{
            articles.removeAll()
            for data in result{
                articles.append(data)
                }
            }
            if refresher.isRefreshing
            {
                refresher.endRefreshing()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func deleteData(){
        articles.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate  else {return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticlesEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        // perform the delete
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
