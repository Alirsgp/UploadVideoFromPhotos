//
//  ContentView.swift
//  UploadVideo
//
//  Created by Ali Mohammadian on 1/19/23.
//

import SwiftUI
import AVFoundation
import PhotosUI
import AVKit
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var data: Data?
    @State private var videoPlayer: AVPlayer?
    @State private var videoThumbnail: UIImage?
    
    private func getVideoThumbnail(asset: AVAsset, assetDurationTime: Int64) {
        debugPrint("Mid point duration time of video is \(assetDurationTime / 2)")
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(
                at: CMTimeMake(value: assetDurationTime, timescale: 60),
                actualTime: nil
            )
            let thumbnail = UIImage(cgImage: thumbnailCGImage)
            videoThumbnail = thumbnail
        } catch let error {
            print("Error generating thumbnail: \(error)")
        }
    }
    
    var body: some View {
        VStack {
//            if let videoPlayer = videoPlayer {
//                VideoPlayer(player: videoPlayer)
//                    .frame(maxWidth: .infinity,
//                           maxHeight: .infinity,
//                           alignment: .topLeading
//                    )
//            }
            if let thumbnail = videoThumbnail {
                Image(uiImage: thumbnail)
                    .resizable().frame(width: 70, height: 70)
                    .padding()
            }
            Spacer()
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 1,
                matching: .videos
            ) {
                Text("Pick Video")
            }
            .onChange(of: selectedItems) { newValue in
                guard let item = selectedItems.first else {
                    return
                }
                item.loadTransferable(type: Data.self) { result in
                    // Loading screen....
                    switch result {
                    case .success(let data):
                        if let data = data {
                            self.data = data
                            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("tempVideo").appendingPathExtension("mp4")
                            let wasFileWritten = (try? data.write(to: tmpFileURL, options: [.atomic])) != nil
                            if !wasFileWritten {
                                print("File was NOT Written")
                            } else {
                                //Create an AVAsset with the url
                                let videoAsset = AVAsset(url: tmpFileURL)
                                let duration = videoAsset.duration
                                let durationTime = CMTimeGetSeconds(duration)
                                getVideoThumbnail(asset: videoAsset, assetDurationTime: Int64(durationTime))
                                
//                                let titleComposition = AVMutableVideoComposition(asset: videoAsset) { request in
//
//
//                                    //Create a white shadow for the text
//                                    let whiteShadow = NSShadow()
//                                    whiteShadow.shadowBlurRadius = 5
//                                    whiteShadow.shadowColor = UIColor.white
//                                    let attributes = [
//                                        NSAttributedString.Key.foregroundColor : UIColor.blue,
//                                        NSAttributedString.Key.font : UIFont(name: "Marker Felt", size: 36.0)!,
//                                        NSAttributedString.Key.shadow : whiteShadow
//                                    ]
//
//                                    //Create an Attributed String
//                                    let waterfallText = NSAttributedString(string: "Waterfall!", attributes: attributes)
//
//                                    //Convert attributed string to a CIImage
//                                    let textFilter = CIFilter.attributedTextImageGenerator()
//                                    textFilter.text = waterfallText
//                                    textFilter.scaleFactor = 4.0
//
//                                    //Center text and move 200 px from the origin
//                                    //source image is 720 x 1280
//                                    let positionedText = textFilter.outputImage!.transformed(by: CGAffineTransform(translationX: (request.renderSize.width - textFilter.outputImage!.extent.width)/2, y: 200))
//
//
//                                    //Compose text over video image
//                                    request.finish(with: positionedText.composited(over: request.sourceImage), context: nil)
//
//                                }
                                let avPlayerItem = AVPlayerItem(asset: videoAsset)
//                                avPlayerItem.videoComposition = titleComposition
                                videoPlayer = AVPlayer(playerItem: avPlayerItem)
                            }
                        } else {
                            print("Data is nil")
                        }
                    case .failure(let failure):
                        fatalError("\(failure.localizedDescription)")
                    }
                }
            }
        }
        
    }
}
