import XCTest
import Quick

@testable import BeethovenTests

QCKMain([
    ConfigSpec.self,
    EstimationFactorySpec.self,
    EstimatorSpec.self,
    ArrayExtensionsSpec.self,
    BufferSpec.self,
    FFTTransformerSpec.self,
])
