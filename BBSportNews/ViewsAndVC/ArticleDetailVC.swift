//
//  DetailViewController.swift
//  BBSportNews
//
//  Created by dat on 10/23/17.
//  Copyright © 2017 dat. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailVC: UIViewController {

    @IBOutlet weak var uiWebView: UIWebView!
    // wkWebView just work on IOS >= 8.0
    @available(iOS 8.0, *)
    lazy var wkWebView: WKWebView = { [weak self] in
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self?.view.insertSubview(webView, at: 0)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
        }()
    
    @IBOutlet weak var loadingAIV: UIActivityIndicatorView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    func configureView() {
        if let article = article {
            self.title = article.title
            if uiWebView != nil {
                loadingAIV.startAnimating()
                Manager4Network.shared.getDataFromUrl(urlString: article.url!, completionHandler: {
                    [weak self](data, error,_) in
                    if let data = data {
                        let htmlString = String(data: data, encoding: String.Encoding.utf8)!
                        self?.showHtmlContent(htmlString, urlString: article.url!)
                        self?.networkErrorLabel.isHidden = true
                    } else {
                        // network fail
                        self?.loadingAIV.stopAnimating()
                        self?.networkErrorLabel.isHidden = false
                    }
                })
            }
        }
    }
    
    func showHtmlContent(_ htmlString: String, urlString: String)  {
        if #available(iOS 8, *) {
            wkWebView.loadHTMLString(htmlString, baseURL: URL(string: urlString))
        } else {
            uiWebView.loadHTMLString(htmlString, baseURL: URL(string: urlString))
        }
    }
    
    func setUpWebview() {
        // wkWebView just work on IOS >= 8.0
        if #available(iOS 8, *) {
            uiWebView.isHidden = true
        } else {
            uiWebView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setUpWebview()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // start listenning notification for network state
        Broadcaster.register(NetCtrlerNoti.self, observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // stop listenning notification for network state
        Broadcaster.unregister(NetCtrlerNoti.self, observer: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    var article: Article? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

// MARK: - process for UIWebview and WKWebview state
extension ArticleDetailVC {
    public func webViewDidStartLoad() {
        print("start to load")
    }
    public func webViewDidFinishLoad() {
        print("finish to load")
        networkErrorLabel.isHidden = true
        loadingAIV.stopAnimating()
    }
    public func didFailLoad(_ error: Error) {
        print(error.localizedDescription)
        loadingAIV.stopAnimating()
        networkErrorLabel.isHidden = false
    }
}

// MARK: - UIWebViewDelegate
extension ArticleDetailVC: UIWebViewDelegate {
    public func webViewDidStartLoad(_ webView: UIWebView) {
        webViewDidStartLoad()
    }
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        webViewDidFinishLoad()
    }
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        didFailLoad(error)
    }
}

// MARK: - WKNavigationDelegate
extension ArticleDetailVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webViewDidStartLoad()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewDidFinishLoad()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        didFailLoad(error)
    }
}

// MARK: - set contraint for customize view
extension ArticleDetailVC {
    func setupConstraints() {
        for attribute: NSLayoutAttribute in [.centerX, .centerY, .width, .height] {
            // wkWebView just work on IOS >= 8.0
            if #available(iOS 8, *) {
                view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: attribute,
                                                  relatedBy: .equal, toItem: view, attribute: attribute,
                                                  multiplier: 1, constant: 0))
            }
        }
    }
}

// MARK: - Handle network status
extension ArticleDetailVC: NetCtrlerNoti {
    func networkActivated(){
        if networkErrorLabel.isHidden == false {
            // reload page
            configureView()
        }
    }
}

