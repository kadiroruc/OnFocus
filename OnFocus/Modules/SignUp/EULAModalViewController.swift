//
//  EULAModalViewController.swift
//  OnFocus
//
//  Created by Abdulkadir Oruç on 8.07.2025.
//

import UIKit
import WebKit

protocol EULAModalDelegate: AnyObject {
    func eulaDidAccept()
    func eulaDidReject()
}

class EULAModalViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    weak var delegate: EULAModalDelegate?
    private let webView = WKWebView()
    private let acceptButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    private var hasScrolledToBottom = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        setupButtons()
        loadEULA()
    }

    private func setupWebView() {
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
    }

    private func setupButtons() {
        acceptButton.setTitle(L10n.EULA.accept, for: .normal)
        acceptButton.isEnabled = false
        acceptButton.backgroundColor = UIColor(hex: Constants.Colors.mintGreen)
        acceptButton.alpha = 0.5
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 8
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        view.addSubview(acceptButton)

        rejectButton.setTitle(L10n.EULA.reject, for: .normal)
        rejectButton.isEnabled = true
        rejectButton.backgroundColor = UIColor(hex: Constants.Colors.softOrange)
        rejectButton.setTitleColor(.white, for: .normal)
        rejectButton.layer.cornerRadius = 8
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
        view.addSubview(rejectButton)

        NSLayoutConstraint.activate([
            acceptButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            acceptButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            acceptButton.heightAnchor.constraint(equalToConstant: 44),
            acceptButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),

            rejectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            rejectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            rejectButton.heightAnchor.constraint(equalToConstant: 44),
            rejectButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8)
        ])
    }

    private func loadEULA() {
        if let url = Bundle.main.url(forResource: "EULA", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            let html = L10n.EULA.fallbackHtml
            webView.loadHTMLString(html, baseURL: nil)
        }
        hasScrolledToBottom = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY + frameHeight >= contentHeight - 10 {
            if !hasScrolledToBottom {
                hasScrolledToBottom = true
                acceptButton.isEnabled = true
                acceptButton.alpha = 1.0
            }
        }
    }

    @objc private func acceptTapped() {
        delegate?.eulaDidAccept()
        dismiss(animated: true)
    }

    @objc private func rejectTapped() {
        delegate?.eulaDidReject()
        dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.setContentOffset(.zero, animated: false)
    }
}
