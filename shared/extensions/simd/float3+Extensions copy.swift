extension float3 {
    var normalized: float3 {
        let mag = sqrt(x * x + y * y + z * z)
        return float3(
            x / mag,
            y / mag,
            z / mag
        )
    }
    
    var homogenized: float4 {
        return float4(x, y, z, 1)
    }
    
    // cross product
    func cross(_ rhs: float3) -> float3 {
        return float3(
            self.y * rhs.z - self.z * rhs.y,
            self.z * rhs.x - self.x * rhs.z,
            self.x * rhs.y - self.y * rhs.x
        )
    }
    
    /*
     From https://codereview.stackexchange.com/questions/43928/algorithm-to-get-an-arbitrary-perpendicular-vector:
     */
    func arbitraryPerpendicular() throws -> float3 {
        if x == 0 && y == 0 {
            if z == 0 {
                throw GeometryError.ZeroVector
            }
            return float3(0, 1, 0)
        }
        return float3(-y, x, 0)
    }
    
    func axisRotationMatrix(theta: Float) -> float4x4 {
        return float4x4.makeRotate(theta, x, y, z)
    }
}
