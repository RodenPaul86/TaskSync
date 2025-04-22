//
//  legalHelper.swift
//  TaskSync
//
//  Created by Paul  on 4/22/25.
//

import SwiftUI
import WebKit
import UIKit

struct HTMLView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

class HTMLToPDFConverter: NSObject, WKNavigationDelegate {
    private var webView: WKWebView!
    private var htmlContent: String
    private var completion: ((URL?) -> Void)?
    
    init(html: String) {
        self.htmlContent = html
        super.init()
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
    }
    
    func generatePDF(completion: @escaping (URL?) -> Void) {
        self.completion = completion
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let config = WKPDFConfiguration()
        webView.createPDF(configuration: config) { result in
            switch result {
            case .success(let data):
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("Exported.pdf")
                do {
                    try data.write(to: tempURL)
                    self.completion?(tempURL)
                } catch {
                    print("Failed to write PDF:", error)
                    self.completion?(nil)
                }
            case .failure(let error):
                print("PDF generation failed:", error)
                self.completion?(nil)
            }
        }
    }
}
