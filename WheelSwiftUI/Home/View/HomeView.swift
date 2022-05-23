//
//  HomeView.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import SwiftUI
import Photos
import PhotosUI

struct HomeView: View {
    @State private var photos = [Photo]()
    @State var height = UIScreen.main.bounds.height
    @State var circleWidth = UIScreen.main.bounds.width / 3
    @StateObject var homeData = HomeViewModel()
    @State var angle = 0
    @State var dragOffSet: CGSize = .zero
    @State var rotate = false
    @State var numberOfPhotos = 10
    @State var isPhotosEmpty = false
    @State var isPhotosAccessDenied = false
    @State var currentIndex: Int = 0
    @State private var position = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height / 2) - (UIScreen.main.bounds.width / 6) )
    private var dragDiametr: CGFloat = UIScreen.main.bounds.width / 3
    
    var body: some View {
        ZStack{
            TabView(selection: $currentIndex) {
                ForEach(photos.indices, id: \.self){ index in
                    GeometryReader { proxy in
                        photos[index].photo
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .border(Color.black)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 1), value: currentIndex)
            .ignoresSafeArea()
            
            Color.white.opacity(0)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            QueueCarousel(spacing: numberOfPhotos > 14 ? -75 : -60 ,index: $currentIndex, items: photos) { photo in
                CardView(photo: photo)
            }
            .offset(x:getRect().width / 5, y: getRect().height / 1.3)
            .alert("Empty Photos Folder", isPresented: $isPhotosEmpty, actions: {
                Button("Ok", role: .cancel){}
            })
            
            ZStack{
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: circleWidth + 55, height: circleWidth + 55)
                
                Text("\(Int(self.angle))")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.black)
                    .rotationEffect(.init(degrees: -Double(angle)))
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
                    .rotationEffect(.init(degrees: Double(angle)))
                    .position(x: position.x, y: position.y)
                    .rotationEffect(.degrees(rotate ? 360 : 0))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 2.0)){
                            rotateAtRandom()
                            self.rotate.toggle()
                        }
                    }
                
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                self.rotateTo(value: value.location)
                            })
                            .onEnded({ value in
                                homeData.onEnded(value: value)
                            })
                    )
                
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 45, height: 45)
                
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.black)
                    .frame(width: 45, height: 45)
                    .background(Color.clear)
                    .clipShape(Circle())
                    .onTapGesture {
                        withAnimation {
                            reloadPhotos()
                        }
                    }
            }
        }
        
        .alert(isPresented: $isPhotosAccessDenied, content: {
            Alert(title: Text("Please Allow Access to Photo Library"), message: nil, dismissButton: .cancel())
        })
        .ignoresSafeArea(.all, edges: .all)
        .onAppear {
            requestAuthorizationToPhotos()
        }
    }
    
    @ViewBuilder
    func CardView(photo: Photo)-> some View {
        VStack(spacing: 10){
            GeometryReader{ proxy in
                photo.photo
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .cornerRadius(26)
            }
            .frame(width: getRect().width / 4 ,height: getRect().height / 4)
        }
        .padding(.vertical, 80)

    }
    
    func rotateAtRandom() {
        let randomInt1 = Int.random(in: 0..<Int(UIScreen.main.bounds.width))
        let randomInt2 = Int.random(in: 0..<Int(UIScreen.main.bounds.height))
        let nextPoint = CGPoint(x: randomInt1, y: randomInt2)
        rotateTo(value: nextPoint)
    }
    
    func rotateTo(value: CGPoint){
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        self.angle = homeData.onChanged(value: value, center: center)
        getIndexFrom(angle: self.angle)
        let currentLocation = value
        let distance = center.distance(to:currentLocation)
        if distance > self.dragDiametr / 1.5 {
            let d = (self.dragDiametr / 2) / distance
            let newLocationX = (currentLocation.x - center.x) * d+center.x
            let newLocationY = (currentLocation.y - center.y) * d+center.y
            withAnimation {
                self.position = CGPoint(x: newLocationX, y: newLocationY)
            }
        }
    }
    
    func getIndexFrom(angle: Int){
        let totalPhotos = photos.count
        if totalPhotos > 0 {
            let degreesPerPhoto = 360 / totalPhotos
            let index = angle / degreesPerPhoto
            currentIndex = index
        } else {
            print("NO Photos")
        // TODO: add alert 
        }
    }
    
    
    func reloadPhotos(){
        numberOfPhotos = Int.random(in: 10...20)
        fetchPhotos()
    }
    
    func fetchPhotos(){
        photos = []
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResults: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResults.count > 0{
            if fetchResults.count <= 20 {
                for _ in 0 ... fetchResults.count {
                    let randomImageIndex = Int.random(in: 0..<fetchResults.count)
                    imageManager.requestImage(for: fetchResults.object(at: randomImageIndex), targetSize: CGSize(width: 300, height: 600), contentMode: .aspectFit, options: requestOptions) { (image, _ ) in
                        if let image = image {
                            let photo = Photo(photo: Image(uiImage: image))
                            photos.append(photo)
                        }
                    }
                }
            } else {
                for _ in 0 ..< numberOfPhotos {
                    let randomImageIndex = Int.random(in: 0..<fetchResults.count)
                    imageManager.requestImage(for: fetchResults.object(at: randomImageIndex ), targetSize: CGSize(width: 300, height: 600), contentMode: .aspectFit, options: requestOptions) { (image, _ ) in
                        if let image = image {
                            let photo = Photo(photo: Image(uiImage: image))
                            photos.append(photo)
                        }
                    }
                }
            }
        } else {
            isPhotosEmpty = true
        }
    }
    
    func requestAuthorizationToPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    fetchPhotos()
                }
            default:
               isPhotosAccessDenied = true
            }
        }
    }
}


