//
//  ViewControllerPreview.swift
//  Test
//
//  Created by Abdulkadir Oruç on 12.04.2025.
//

import SwiftUI
import UIKit

struct ViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {

    private let builder: () -> ViewController

    init(_ builder: @autoclosure @escaping () -> ViewController) {
        self.builder = builder
    }

    init(fromStoryboard name: String = "Main", identifier: String? = nil) {
        self.builder = {
            let storyboard = UIStoryboard(name: name, bundle: nil)
            let id = identifier ?? String(describing: ViewController.self)
            guard let vc = storyboard.instantiateViewController(withIdentifier: id) as? ViewController else {
                fatalError("Storyboard ID or type mismatch for \(id)")
            }
            return vc
        }
    }

    func makeUIViewController(context: Context) -> ViewController {
        builder()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
