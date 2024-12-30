//
//  ContentView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel: DiaryViewModel
    @StateObject private var slideViewModel = SlideViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var activeTextId: UUID?
    @State private var isTyping: Bool = false
    @State private var isDraggingUp = false
    
    init(containerWidth: CGFloat) {
        _viewModel = StateObject(wrappedValue: DiaryViewModel(containerWidth: containerWidth))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let contentWidth = geometry.size.width - 32
            
            ZStack(alignment: .top) {
                // Background
                Color(hex: "#FBFBFB").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HeaderView(slideViewModel: slideViewModel)
                        .zIndex(1)
                        .frame(width: geometry.size.width)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            DateComponent()
                                .padding(.top, 12)
                                .frame(width: contentWidth)
                            
                            Group {
                                if let _ = viewModel.currentEntry {
                                    PhotoCanvasView(
                                        viewModel: viewModel,
                                        activeTextId: $activeTextId,
                                        isTyping: $isTyping,
                                        selectedItem: $selectedItem,
                                        containerWidth: contentWidth
                                    )
                                } else {
                                    PhotoPickerView(
                                        selectedItem: $selectedItem,
                                        containerWidth: contentWidth
                                    )
                                }
                            }
                            .padding(.top, 12)
                            
                            Spacer()
                            
                            if viewModel.currentEntry == nil {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    
                                    Text("PAST")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray)
                                        .monospaced()
                                        .tracking(2)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                }
                
                // Calendar View
                VStack {
                    Spacer()
                    MonthCalendarView()
                        .padding(.horizontal)
                        .frame(height: geometry.size.height * 0.9)
                        .background(Color(hex: "#FBFBFB"))
                        .offset(y: min(geometry.size.height - slideViewModel.slideOffset, geometry.size.height))
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.height
                        if translation < 0 { // Dragging up
                            isDraggingUp = true
                            slideViewModel.slideOffset = translation
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.height
                        let threshold: CGFloat = geometry.size.height * 0.2
                        
                        if translation < -threshold {
                            slideViewModel.showCalendar()
                        } else {
                            slideViewModel.hideCalendar()
                        }
                        isDraggingUp = false
                    }
            )
        }
        .onChange(of: selectedItem) { oldItem, newItem in
            if let item = newItem {
                loadImage(from: item)
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            if let imageData = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: imageData) {
                await MainActor.run {
                    if viewModel.currentEntry != nil {
                        viewModel.replaceCurrentPhoto(uiImage)
                    } else {
                        viewModel.addNewPhoto(uiImage)
                    }
                }
            }
            await MainActor.run {
                selectedItem = nil
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(containerWidth: PreviewData.containerWidth)
    }
}
#endif
