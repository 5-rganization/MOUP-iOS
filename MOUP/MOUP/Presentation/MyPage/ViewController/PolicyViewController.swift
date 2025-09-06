//
//  PolicyViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 8/11/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

struct TermsArticle: Decodable {
    let article: String
    let title: String
    let content: [String]
}

final class PolicyViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private var articles: [TermsArticle] = []
    private let fileName: String
    private let screenTitle: String
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private lazy var navigationBar = BaseNavigationBar(title: screenTitle)
    
    private let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "ContentCell")
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 44
    }
    
    // MARK: - Initializer
    
    init(fileName: String, title: String) {
        self.fileName = fileName
        self.screenTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        loadTerms()
    }
    
    func loadTerms() {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([TermsArticle].self, from: data) else {
            print("JSON 로드 실패: \(fileName).json")
            return
        }
        self.articles = decoded
        tableView.reloadData()
    }
}

private extension PolicyViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setTableView()
        setBindings()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(
            navigationBar,
            tableView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    // MARK: - setBindings
    func setBindings() {
        navigationBar.rx.backBtnTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension PolicyViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles[section].content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = articles[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
        cell.textLabel?.text = article.content[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        cell.textLabel?.font = .bodyMedium(12)
        cell.textLabel?.setLineSpacing(.bodyMedium)
        cell.textLabel?.textColor = .gray900
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel().then {
            $0.text = "\(articles[section].article) (\(articles[section].title))"
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .black
            $0.numberOfLines = 0
            $0.backgroundColor = .white
        }

        let containerView = UIView().then {
            $0.backgroundColor = .white
            $0.addSubview(label)
        }

        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
