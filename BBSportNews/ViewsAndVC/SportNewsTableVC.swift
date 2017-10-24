//
//  MasterViewController.swift
//  BBSportNews
//
//  Created by dat on 10/23/17.
//  Copyright © 2017 dat. All rights reserved.
//

import UIKit

class SportNewsTableVC: UITableViewController {

    var articleDetailVC: ArticleDetailVC? = nil
    
    var articles:[Article]?
    lazy var loadingAIV: UIActivityIndicatorView = { [weak self] in
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.hidesWhenStopped = true
        self?.view.addSubview(activityView)
        return activityView
    }()
    lazy var networkErrorLabel: UILabel = { [weak self] in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Network Error! Please try again later!"
        label.isHidden = true
        self?.view.addSubview(label)
        return label
        }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // trick to hide separator of empty cell
        tableView.tableFooterView = UIView()
        // show loading indicator
        loadingAIV.startAnimating()
        fetchArticlesData()
        // set up autolayout
        setupConstraints()
        

        if let split = splitViewController {
            let controllers = split.viewControllers
            articleDetailVC = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ArticleDetailVC
        }
        
        // set up pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshArticlesData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshArticlesData(_ sender: Any) {
        // Fetch Weather Data
        Manager4Network.shared.clearRequestCache()
        Manager4CacheArticle.shared.cancelAllArticles()
        fetchArticlesData()
    }
    
    func enableNetworkError(_ enable: Bool) {
        if enable && articles == nil {
            // show network error label
            self.networkErrorLabel.isHidden = false
        } else {
            // hide network error label
            self.networkErrorLabel.isHidden = true
        }
    }
    
    /// fetch list articles from server
    private func fetchArticlesData() {
        Manager4Network.shared.getArticlesListFromSV(completionHandler: {
            [weak self] bbcSportNews, error, _ in
            self?.loadingAIV.stopAnimating()
            if let bbcSportNews = bbcSportNews {
                // if get any bbc sport news from server
                self?.articles = bbcSportNews.articles
                Manager4CacheArticle.shared.cacheAllArticles(articles: self?.articles)
                self?.tableView.reloadData()
                self?.enableNetworkError(false)
            } else {
                self?.enableNetworkError(true)
            }
            self?.refreshControl?.endRefreshing()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow,
                let articles = articles{
                // pass article to detail view
                let article = articles[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! ArticleDetailVC
                controller.article = article
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let articles = articles else {
            return 0
        }
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articlecell", for: indexPath)

        if let articleInfoCell = cell as? ArticleInfoTVCell,
            let articles = articles {
            let article = articles[indexPath.row]
            articleInfoCell.newsTitleLabel.text = article.title
            articleInfoCell.newsDescriptionLabel.text = article.description
            articleInfoCell.timesampLabel.text = article.publishedAt
            articleInfoCell.avatarUrlStr = article.urlToImage
            if let urlImage = article.urlToImage {
                Manager4Network.shared.getImageFromUrl(urlString: urlImage, completionHandler: { (image, _) in
                    if articleInfoCell.avatarUrlStr == urlImage {
                        articleInfoCell.newsImageView.image = image
                    }
                })
            }
        }
        return cell
    }


}

// MARK: - set contraint for customize view
extension SportNewsTableVC {
    
    func setupConstraints() {
        for attribute: NSLayoutAttribute in [.centerX, .centerY] {
            view.addConstraint(NSLayoutConstraint(item: loadingAIV, attribute: attribute,
                                             relatedBy: .equal, toItem: view, attribute: attribute,
                                             multiplier: 1, constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: networkErrorLabel, attribute: attribute,
                                             relatedBy: .equal, toItem: view, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
    }
}

