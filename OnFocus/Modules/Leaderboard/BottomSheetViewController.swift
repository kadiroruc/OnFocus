//
//  BottomSheetViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 20.04.2025.
//

import UIKit

protocol BottomSheetViewControllerInterface: AnyObject {
    func updateWithProfiles(_ profiles: [ProfileModel])
}

class BottomSheetViewController: UIViewController {

    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var collectionView: UICollectionView!
    private var profiles: [ProfileModel] = []

//    private var bottomConstraint: NSLayoutConstraint!
    
    var maxHeight: CGFloat = 0
    var minHeight: CGFloat = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        setupPanGesture()
        
        maxHeight = view.bounds.height * 0.88
        minHeight = view.bounds.height * 0.30
        
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
        collectionView.register(LeaderboardBottomSheetCollectionViewCell.self, forCellWithReuseIdentifier: LeaderboardBottomSheetCollectionViewCell.reuseIdentifier)
        
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

}

extension BottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if profiles.count == 0{
            return 1
        }else{
            return profiles.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LeaderboardBottomSheetCollectionViewCell.reuseIdentifier, for: indexPath) as? LeaderboardBottomSheetCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // Rank 4’den başlıyoruz (ilk 3 üstte olduğu için)
        let rank = indexPath.item + 4
        let profile: ProfileModel
        if profiles.count == 0{
            profile = ProfileModel(nickname: "Example User")
        }else{
            profile = profiles[indexPath.item]
        }
        
        cell.configure(rank: rank, profile: profile)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }

}


extension BottomSheetViewController: BottomSheetViewControllerInterface {
    func updateWithProfiles(_ profiles: [ProfileModel]) {
        self.profiles = profiles
        collectionView.reloadData()
    }
}

//#Preview("LeaderboardViewController"){
//    LeaderboardViewController()
//}

