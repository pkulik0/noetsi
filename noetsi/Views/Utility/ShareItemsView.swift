//
//  ShareView.swift
//  noetsi
//
//  Created by pkulik0 on 12/06/2022.
//

import SwiftUI

/// SwiftUI wrapper around UIKit's UIActivityViewController.
struct ShareItemsView: UIViewControllerRepresentable {
    /// Items to share.
    let activityItems: [Any]

    let applicationActivites: [UIActivity]?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivites)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        return
    }
}
