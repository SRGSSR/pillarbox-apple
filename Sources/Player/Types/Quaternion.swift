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

public enum Quaternion {
    /// Rotates the specified quaternion around the x- and y-axes.
    ///
    /// - Parameters:
    ///   - quaternion: The quaternion to rotate.
    ///   - wx: The angle around the x-axis.
    ///   - wy: The angle around the y-axis.
    /// - Returns: The rotated quaternion.
    public static func rotate(_ quaternion: SCNQuaternion, _ wx: Float, _ wy: Float) -> SCNQuaternion {
        let simdQuaternion = simd_quaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
        let simdRotationAroundX = simd_quaternion(wx, simd_make_float3(1, 0, 0))
        let simdRotationAroundY = simd_quaternion(wy, simd_make_float3(0, 1, 0))
        let rotatedSimdQuaternion = simd_mul(simdRotationAroundY, simd_mul(simdQuaternion, simdRotationAroundX))
        let vector = simd_imag(rotatedSimdQuaternion)
        return SCNVector4(vector.x, vector.y, vector.z, simd_real(rotatedSimdQuaternion))
    }
    
    /// Creates a quaternion for a rotation around the specified axis.
    ///
    /// - Parameters:
    ///   - radians: The rotation angle.
    ///   - x: The axis x-component.
    ///   - y: The axis y-component.
    ///   - z: The axis z-component.
    /// - Returns: The quaternion.
    public static func quaternionWithAngleAndAxis(_ radians: Float, _ x: Float, _ y: Float, _ z: Float) -> SCNQuaternion {
        let simdQuaternion = simd_quaternion(radians, simd_make_float3(x, y, z))
        let vector = simd_imag(simdQuaternion)
        return SCNVector4(vector.x, vector.y, vector.z, simd_real(simdQuaternion))
    }

#if os(iOS)
    /// Returns a quaternion describing the camera orientation which should be used when the device is held with a
    /// given attitude (orientation in space), so that it always faces the content in front of the device.
    ///
    /// - Parameters:
    ///   - attitude: The current device orientation in space, as returned by a `CMMotionManager` instance.
    ///   - interfaceOrientation: The interface orientation.
    /// - Returns: The quaternion.
    ///
    /// See `CMAttitude` documentation for more information.
    public static func cameraOrientationForAttitude(_ attitude: CMAttitude, interfaceOrientation: UIInterfaceOrientation) -> SCNQuaternion {
        // Based on: https://gist.github.com/travisnewby/96ee1ac2bc2002f1d480
        // Also see https://stackoverflow.com/a/28784841/760435
        let quaternion = attitude.quaternion
        let simdQuaternion = simd_quaternion(Float(quaternion.x), Float(quaternion.y), Float(quaternion.z), Float(quaternion.w))
        switch interfaceOrientation {
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
#endif
}
