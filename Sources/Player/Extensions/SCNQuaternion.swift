//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if os(iOS)
import CoreMotion
#endif
import SceneKit
import simd
import UIKit

public extension SCNQuaternion {
    /// The default orientation for monoscopic content.
    ///
    /// Corresponds to a user facing the content with no head tilting.
    static let monoscopicDefault = SCNQuaternionWithAngleAndAxis(0, 1, 0, 0)
}

/// Rotates the specified quaternion around the x- and y-axes.
///
/// - Parameters:
///   - quaternion: The quaternion to rotate.
///   - wx: The angle around the x-axis.
///   - wy: The angle around the y-axis.
/// - Returns: The rotated quaternion.
///
/// For a short introduction to quaternions please check http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-17-quaternions/.
public func SCNQuaternionRotate(_ quaternion: SCNQuaternion, _ wx: Float, _ wy: Float) -> SCNQuaternion {
    let simdQuaternion = simd_quaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    let simdRotationAroundX = simd_quaternion(wx, simd_make_float3(1, 0, 0))
    let simdRotationAroundY = simd_quaternion(wy, simd_make_float3(0, 1, 0))
    let rotatedSimdQuaternion = simd_mul(simdRotationAroundY, simd_mul(simdQuaternion, simdRotationAroundX))
    let vector = simd_imag(rotatedSimdQuaternion)
    return SCNVector4(vector.x, vector.y, vector.z, simd_real(rotatedSimdQuaternion))
}

/// Creates a quaternion with a rotation around the specified axis.
///
/// - Parameters:
///   - radians: The rotation angle.
///   - x: The axis x-component.
///   - y: The axis y-component.
///   - z: The axis z-component.
/// - Returns: The quaternion.
///
/// For a short introduction to quaternions please check http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-17-quaternions/.
public func SCNQuaternionWithAngleAndAxis(_ radians: Float, _ x: Float, _ y: Float, _ z: Float) -> SCNQuaternion {
    let simdQuaternion = simd_quaternion(radians, simd_make_float3(x, y, z))
    let vector = simd_imag(simdQuaternion)
    return SCNVector4(vector.x, vector.y, vector.z, simd_real(simdQuaternion))
}

#if os(iOS)

/// Returns a quaternion matching the provided CoreMotion attitude.
///
/// - Parameters:
///   - attitude: The current device orientation in space, as returned by a `CMMotionManager` instance.
///   - interfaceOrientation: The interface orientation.
/// - Returns: The quaternion.
///
/// Unlike [`CMAttitude/quaternion`](https://developer.apple.com/documentation/coremotion/cmattitude/1616025-quaternion)
/// this property takes the current user interface orientation into account. The method must therefore be called again
/// should the user interface orientation change.
///
/// For a short introduction to quaternions please check http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-17-quaternions/.
public func SCNQuaternionForAttitude(_ attitude: CMAttitude) -> SCNQuaternion {
    // Based on: https://gist.github.com/travisnewby/96ee1ac2bc2002f1d480. Also see https://stackoverflow.com/a/28784841/760435.
    let quaternion = attitude.quaternion
    let simdQuaternion = simd_quaternion(Float(quaternion.x), Float(quaternion.y), Float(quaternion.z), Float(quaternion.w))
    switch UIApplication.shared.firstWindowScene?.interfaceOrientation {
    case .portraitUpsideDown:
        let simdRotationQuaternion = simd_quaternion(.pi / 2, simd_make_float3(1, 0, 0))
        let simdRotatedQuaternion = simd_mul(simdRotationQuaternion, simdQuaternion)
        let vector = simd_imag(simdRotatedQuaternion)
        return SCNQuaternion(x: -vector.x, y: -vector.y, z: vector.z, w: simd_real(simdRotatedQuaternion))
    case .landscapeLeft:
        let simdRotationQuaternion = simd_quaternion(-.pi / 2, simd_make_float3(0, 1, 0))
        let simdRotatedQuaternion = simd_mul(simdRotationQuaternion, simdQuaternion)
        let vector = simd_imag(simdRotatedQuaternion)
        return SCNQuaternion(x: vector.y, y: -vector.x, z: vector.z, w: simd_real(simdRotatedQuaternion))
    case .landscapeRight:
        let simdRotationQuaternion = simd_quaternion(.pi / 2, simd_make_float3(0, 1, 0))
        let simdRotatedQuaternion = simd_mul(simdRotationQuaternion, simdQuaternion)
        let vector = simd_imag(simdRotatedQuaternion)
        return SCNQuaternion(x: -vector.y, y: vector.x, z: vector.z, w: simd_real(simdRotatedQuaternion))
    default:
        let simdRotationQuaternion = simd_quaternion(-.pi / 2, simd_make_float3(1, 0, 0))
        let simdRotatedQuaternion = simd_mul(simdRotationQuaternion, simdQuaternion)
        let vector = simd_imag(simdRotatedQuaternion)
        return SCNQuaternion(x: vector.x, y: vector.y, z: vector.z, w: simd_real(simdRotatedQuaternion))
    }
}

private extension UIApplication {
    var firstWindowScene: UIWindowScene? {
        connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
    }
}

#endif
