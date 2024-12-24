import SwiftUI
import Combine

class OrientationManager: ObservableObject {
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                let orientation = UIDevice.current.orientation
                self.isLandscape = orientation == .landscapeLeft || orientation == .landscapeRight
            }
    }
}

