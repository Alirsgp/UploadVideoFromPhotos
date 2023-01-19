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

struct ContentView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var data: Data?
    @State private var videoPlayer: AVPlayer?
    
    var body: some View {
        VStack {
            if let videoPlayer = videoPlayer {
                VideoPlayer(player: videoPlayer)
                                .frame(width: 320, height: 180, alignment: .center)
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
                                videoPlayer = AVPlayer(url: tmpFileURL)
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
