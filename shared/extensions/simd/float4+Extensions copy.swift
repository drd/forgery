extension float4 {
    var xyz: float3 {
        return float3(x, y, z)
    }
    
    init(_ xyz: float3, _ w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }
}
