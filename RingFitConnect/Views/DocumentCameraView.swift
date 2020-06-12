//
//  DocumentCameraView.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import VisionKit

struct DocumentCameraView: UIViewControllerRepresentable {

    var handler: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let uiViewController = VNDocumentCameraViewController()
        uiViewController.delegate = context.coordinator
        return uiViewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {

    }

    // MARK: - Coordinator

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {

        private var view: DocumentCameraView

        init(_ view: DocumentCameraView) {
            self.view = view
        }

        // MARK: - VNDocumentCameraViewController delegate

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let images = (0..<scan.pageCount).compactMap { scan.imageOfPage(at: $0) }
            controller.dismiss(animated: true, completion: { [weak self] in
                self?.view.handler(images)
            })
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {

        }

    }

}
