//
//  TextRecognizer.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import UIKit
import Vision

enum TextRecognizerError: LocalizedError {

    case errorExtractTextFailed

    var errorDescription: String? {
        switch self {
        case .errorExtractTextFailed:
            return "Unable to extract the text from image.　Take a picture so that the log screen fits into the camera."
        }
    }

}

class TextRecognizer {

    class func recognizeText(from image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []

            // Sort items in the order they are displayed in the upper part of the screen.
            // (In the case of boundingBox, the order of the y is greater).
            let texts: [String] = observations
                .sorted(by: { $0.boundingBox.origin.y > $1.boundingBox.origin.y })
                .compactMap { observation in
                    let canadiates = observation.topCandidates(1)
                    if canadiates.isEmpty {
                        return nil
                    }

                    return canadiates[0].string
                }

            if texts.isEmpty {
                completion(.failure(TextRecognizerError.errorExtractTextFailed))
                return
            }

            print(texts)

            completion(.success(texts))
        }

        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try? handler.perform([request])
    }

}
