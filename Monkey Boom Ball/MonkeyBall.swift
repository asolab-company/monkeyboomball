import UIKit
import WebKit

class WakePlan: UIViewController, WKNavigationDelegate {

    private var url: URL!
    private var webView: WKWebView!

    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupWebView()
        loadURL()
    }

    private func setupBackground() {
        self.view.backgroundColor = .black
        overrideUserInterfaceStyle = .dark
    }

    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.isOpaque = true

        self.view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }
}
