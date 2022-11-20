//
//  ViewController.swift
//  Example
//
//  Created by ming on 2022/9/22.
//

import UIKit
import KKXMobile

class ViewController: KKXViewController, KKXCustomSearchView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CollectionViewDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let layout = KKXFlowLayout()
        layout.decorationConfiguration = .init(maskedCornerConfiguration: .init(maskedCorners: .all, cornerRadius: 10), backgroundColor: .green)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInset = UIEdgeInsets(value: 10)
        collectionView.kkx_register(UICollectionViewCell.self)
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isNavigationBarHidden = true
        view.addSubview(kkxNavigationBar)
        kkxNavigationBar.titleLabel.text = "KKXMobile"
        
        kkxNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: kkxNavigationBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: kkxNavigationBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: kkxNavigationBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("扫一扫", for: .normal)
        scanButton.setTitleColor(.black, for: .normal)
        scanButton.titleLabel?.font = .systemFont(ofSize: 16)
        
        scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        
        let alertButton = UIButton(type: .system)
        alertButton.setTitleColor(.black, for: .normal)
        alertButton.setTitle("弹框", for: .normal)
        alertButton.titleLabel?.font = .systemFont(ofSize: 16)
        alertButton.addTarget(self, action: #selector(alertAction), for: .touchUpInside)
        
        kkxNavigationBar.titleLabel.text = "KKXMobile"
        kkxNavigationBar.rightItems = [alertButton, scanButton]
        
        testGradient()
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .red
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 500.0).isActive = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func testGradient() {
        let gradientView = UIImageView()
        view.addSubview(gradientView)
        gradientView.frame = CGRect(x: 20, y: 180, width: 200, height: 200)

        gradientView.image = UIColor.rgba(8, 83, 213).image(CGSize(width: 200, height: 200), radius: 8, strokeColor: .rgba(61, 120, 234))
//        gradientView
//            .maskedCorners(.init(maskedCorners: .all, cornerRadius: 20))
//            .gradient(
//                .init(
//                    colors: [.rgba(242, 219, 178), .rgba(238, 191, 120)],
//                    startPoint: .init(x: 0, y: 0.5),
//                    endPoint: .init(x: 1, y: 0.5)
//                )
//            )
    }
    
    @objc private func scanAction() {
        let controller = KKXScanViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func alertAction() {
        let controller = KKXAlertController(title: "温馨提示")
        controller.message = "修改订单会导致订单停止计时，请谨慎操作，确认无误后再确定修改"
        controller.closePosition = .topRight
        let confirmAction = KKXAlertAction { _ in
            
        }
        confirmAction.button.setAttributedTitle(NSAttributedString(string: "确认修改"), for: .normal)

        let cancelAction = KKXAlertAction()
        cancelAction.button.setAttributedTitle(NSAttributedString(string: "取消"), for: .normal)
        controller.addActions([confirmAction, cancelAction])
        present(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.kkx_dequeueReusableCell(UICollectionViewCell.self, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, hasDecorationViewAt section: Int) -> Bool {
        true
    }
    
    
}

