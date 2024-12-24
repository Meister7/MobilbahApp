import SwiftUI
import WebKit
import AVFoundation

struct ContentView: View {
    
    @State private var screenState: ScreenState = .menu
    @State private var isSoundMuted = true
    @State private var backgroundAudioPlayer: AVAudioPlayer?
    @State private var isDarkMode = true
    @StateObject private var orientationManager = OrientationManager()
    @State private var currentImageIndex = 0
    private let images = ["typeMobile1", "typeMobile2", "typeMobile3"]

    var body: some View {
        switch screenState {
        case .menu:
            if orientationManager.isLandscape {
                ZStack {
                    Image("background")
                        .resizable()
                        .ignoresSafeArea()
                    HStack {
                        VStack(spacing: UIScreen.main.bounds.height * 0.025) {
                            Button {
                                screenState = .play
                                stopBackgroundMusic()
                            } label: {
                                Image("play")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.height * 0.6)
                            }
                            Button {
                                screenState = .music
                            } label: {
                                Image("music")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.height * 0.6)
                            }
                            Button {
                                screenState = .mode
                            } label: {
                                Image("mode")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.height * 0.6)
                            }
                            Button {
                                screenState = .policy
                            } label: {
                                Image("policy")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.height * 0.6)
                            }
                            
                        }
                        
                        Button {
                            currentImageIndex = (currentImageIndex + 1) % images.count
                        } label: {
                            Image(images[currentImageIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.55)
                        }
                        .padding(.top, UIScreen.main.bounds.height * 0.08)
                        
                    }
                    
                }
            } else {
                ZStack {
                    Image("background")
                        .resizable()
                        .ignoresSafeArea()
                    VStack(spacing: UIScreen.main.bounds.height * 0.025) {
                        Button {
                            screenState = .play
                            stopBackgroundMusic()
                        } label: {
                            Image("play")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                        }
                        Button {
                            screenState = .music
                        } label: {
                            Image("music")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                        }
                        Button {
                            screenState = .mode
                        } label: {
                            Image("mode")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                        }
                        Button {
                            screenState = .policy
                        } label: {
                            Image("policy")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                        }
                        Button {
                            currentImageIndex = (currentImageIndex + 1) % images.count
                        } label: {
                            Image(images[currentImageIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                        }
                        .padding(.top, UIScreen.main.bounds.height * 0.08)
                    }
                }
                .onAppear {
                    setupAudioPlayer()
                    if !isSoundMuted {
                        playBackgroundMusic()
                    }
                }
            }
            
        case .music:
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Button {
                            screenState = .menu
                        } label: {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.05)
                                .foregroundStyle(.white)
                        }
                        .padding(.leading, 25)
                        .padding(.top, 25)
                        Spacer()
                    }
                    Spacer()
                    Button {
                        isSoundMuted.toggle()
                        isSoundMuted ? stopBackgroundMusic() : playBackgroundMusic()
                    } label: {
                        Image(isSoundMuted ? "soundOff" : "soundOn")
                            .resizable()
                            .scaledToFit()
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        case .mode:
            ZStack {
                Image("background")
                     .resizable()
                   .ignoresSafeArea()
               VStack {
                   HStack {
                       Button {
                           screenState = .menu
                       } label: {
                           Image(systemName: "chevron.backward")
                               .resizable()
                               .scaledToFit()
                               .frame(width: UIScreen.main.bounds.width * 0.05)
                               .foregroundStyle(.white)
                       }
                       .padding(.leading, 25)
                       .padding(.top, 25)
                       Spacer()
                   }
                   Spacer()
                   Button {
                       isDarkMode.toggle()
                   } label: {
                       Image(isDarkMode ? "darkModeOff" : "darkModeOn")
                           .resizable()
                           .scaledToFit()
                   }
                   .padding()
                   
                   Spacer()
               }
           }
        case .play:
            CustomWebView(selectedTexture: images[currentImageIndex], isSoundMuted: $isSoundMuted, currentScreen: $screenState)
        case .policy:
            WebView(urlString: "https://google.com")
        case .typeMobile:
            CustomWebView(selectedTexture: images[currentImageIndex], isSoundMuted: $isSoundMuted, currentScreen: $screenState)
        }
    }
    
    private func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                backgroundAudioPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundAudioPlayer?.numberOfLoops = -1
                backgroundAudioPlayer?.volume = 0.2
                backgroundAudioPlayer?.prepareToPlay()
            } catch {
                print("Audio Player Error: \(error.localizedDescription)")
            }
        }
    }

    private func playBackgroundMusic() {
        backgroundAudioPlayer?.play()
    }

    private func stopBackgroundMusic() {
        backgroundAudioPlayer?.stop()
        backgroundAudioPlayer?.currentTime = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum  ScreenState {
    case music, mode, play, policy, typeMobile, menu
}
