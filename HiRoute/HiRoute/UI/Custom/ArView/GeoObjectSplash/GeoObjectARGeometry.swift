//
//  GeoObjectARGeometry.swift
//  HiRoute
//
//  Created by Jupond on 3/7/26.
//

import CoreLocation
import simd

// AR 월드 좌표계의 기준점이다.
// GPS 좌표는 위도/경도라서 ARView의 x/y/z 좌표와 바로 맞지 않는다.
// 그래서 앱 시작 시점의 위치/고도/방향을 origin으로 잡고, 이후 목표 GPS를 이 기준점 대비 몇 m 떨어졌는지 변환한다.
struct GeoObjectARWorldOrigin {
    // 기준 위도/경도다. 보통 AR 세션을 시작한 사용자 위치가 된다.
    let coordinate: CLLocationCoordinate2D
    // 기준 고도다. 목표 지점과의 높이 차이를 AR y축으로 바꿀 때 쓴다.
    let altitude: CLLocationDistance
    // 기준 방향이다. 사용자가 처음 바라보던 방향을 AR z축과 맞추는 데 쓴다.
    let headingDegrees: CLLocationDirection
}

// GPS 좌표를 RealityKit/ARKit 월드 좌표로 바꾸는 수학 유틸리티다.
enum GeoObjectARGeometry {
    // origin에서 target까지의 동쪽/북쪽 거리 차이를 meter 단위로 계산한다.
    // 반환값 x = east, y = north 이다.
    static func meterOffset(
        from origin: CLLocationCoordinate2D,
        to target: CLLocationCoordinate2D
    ) -> SIMD2<Double> {
        // WGS84 지구 반지름 근사값이다. 짧은 거리 AR 배치에서는 이 정도 근사로 충분하다.
        let earthRadius = 6_378_137.0
        // 삼각함수 계산을 위해 degree를 radian으로 변환한다.
        let originLatitude = origin.latitude * .pi / 180
        let latitudeDelta = (target.latitude - origin.latitude) * .pi / 180
        let longitudeDelta = (target.longitude - origin.longitude) * .pi / 180

        // 위도 차이는 거의 남북 거리로 바로 환산된다.
        let north = latitudeDelta * earthRadius
        // 경도 1도당 실제 거리는 위도에 따라 달라지므로 cos(latitude)를 곱한다.
        let east = longitudeDelta * earthRadius * cos(originLatitude)
        return SIMD2(east, north)
    }

    // GPS 목표 좌표를 AR 월드 좌표의 x/y/z 이동값으로 변환한다.
    static func worldTranslation(
        from origin: GeoObjectARWorldOrigin,
        to target: CLLocationCoordinate2D,
        targetAltitude: CLLocationDistance
    ) -> SIMD3<Float> {
        // 먼저 GPS 두 점 사이를 east/north meter 오프셋으로 바꾼다.
        let offset = meterOffset(from: origin.coordinate, to: target)
        // 사용자의 시작 heading을 radian으로 바꾼다.
        let heading = Float(origin.headingDegrees * .pi / 180)
        let east = Float(offset.x)
        let north = Float(offset.y)

        // east/north 좌표를 사용자 시작 방향 기준의 AR x/z 좌표로 회전시킨다.
        // ARKit에서 카메라 앞쪽은 보통 -z 방향이므로 z에는 음수 부호가 들어간다.
        let x = east * cos(heading) - north * sin(heading)
        let z = -(east * sin(heading) + north * cos(heading))
        // 고도 차이는 AR y축으로 사용한다.
        let y = Float(targetAltitude - origin.altitude)
        return SIMD3<Float>(x, y, z)
    }
}
