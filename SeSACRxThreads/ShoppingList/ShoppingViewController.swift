//
//  ShoppingViewController.swift
//  SeSACRxThreads
//
//  Created by 박소진 on 2023/11/04.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingViewController: UIViewController {
    
    let containerView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        return view
    }()
    
    let textField = {
        let view = UITextField()
        view.backgroundColor = .clear
        view.clearButtonMode = .whileEditing
        view.placeholder = "무엇을 구매하실 건가요?"
        view.font = .systemFont(ofSize: 15, weight: .light)
        return view
    }()
    
    let addButton = {
        let view = UIButton()
        view.setTitle("추가", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 50
        return view
    }()
    
    let viewModel = ShoppingViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "쇼핑"
        configure()
        setConstraints()
        bind()
    }
    
    func bind() {
        
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                cell.listLabel.text = element
            }
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty, resultSelector: { _, text in
                return text
            })
            .subscribe(with: self) { owner, text in
                owner.viewModel.insertData(text: text)
                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .subscribe { [weak self] index, text in
                let vc = ModifyViewController()
                vc.data = text
                vc.completion = { [weak self] text in
                    self?.viewModel.updateData(at: index.row, text: text)
                }
                self?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(with: self) { owner, index in
                owner.viewModel.removeData(at: index.row)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func configure() {
        [containerView, tableView].forEach { view.addSubview($0) }
        [textField, addButton].forEach { containerView.addSubview($0) }
    }
    
    private func setConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(70)
        }
        
        addButton.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.width.equalTo(60)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(addButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}
