//
//  ShareView.swift
//  noetsi
//
//  Created by qurrie on 12/06/2022.
//

import SwiftUI

struct ShareItemsView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivites: [UIActivity]?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivites)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        return
    }
}
