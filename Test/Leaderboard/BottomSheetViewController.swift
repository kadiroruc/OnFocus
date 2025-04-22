//
//  BottomSheetViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 20.04.2025.
//

import UIKit

class BottomSheetViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var collectionView: UICollectionView!

    private let maxHeight: CGFloat = 600
    private let minHeight: CGFloat = 216

//    private var bottomConstraint: NSLayoutConstraint!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        setupPanGesture()
        
    }

    private func setupView() {
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
//        if let superview = self.view.superview {
//            view.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        }
        view.heightAnchor.constraint(equalToConstant: maxHeight).isActive = true

    }

    private func setupCollectionView() {
         //Çentik görünümü
        let notchView = UIView()
        notchView.translatesAutoresizingMaskIntoConstraints = false
        notchView.backgroundColor = .systemGray3
        notchView.layer.cornerRadius = 3
        view.addSubview(notchView)

        NSLayoutConstraint.activate([
            notchView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            notchView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            notchView.widthAnchor.constraint(equalToConstant: 40),
            notchView.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 50, height: 80)
        layout.minimumLineSpacing = 15

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: notchView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    private func setupPanGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let superview = self.view.superview else { return }
        let translation = recognizer.translation(in: superview)

        switch recognizer.state {
        case .changed:
            let newY = view.frame.origin.y + translation.y
            if newY >= superview.frame.height - maxHeight && newY <= superview.frame.height - minHeight {
                view.frame.origin.y = newY
                recognizer.setTranslation(.zero, in: superview)
            }
        case .ended:
            let velocity = recognizer.velocity(in: superview).y
            let targetY = velocity > 0 ? (superview.frame.height - minHeight) : (superview.frame.height - maxHeight)

            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = targetY
            }

        default:
            break
        }
    }

    // MARK: - UICollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 20
        cell.clipsToBounds = true
        
        return cell
    }
}

#Preview("LeaderboardViewController"){
    LeaderboardViewController()
}

