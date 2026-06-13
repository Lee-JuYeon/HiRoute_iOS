//
//  GeoObjectARNavGraph.swift
//  HiRoute
//
//  Created by Jupond on 3/7/26.
//

import CoreLocation

// AR 내비게이션 그래프의 한 지점이다.
// 예: 건물 입구, 복도 분기점, 엘리베이터, 계단, 특정 전시물 위치 같은 것들이 node가 될 수 있다.
struct GeoObjectARNavNode: Identifiable {
    // 서버/DB에서 안정적으로 식별할 수 있는 고유 ID다.
    let id: String
    // 사용자에게 보여줄 이름이다.
    let name: String
    // 이 지점의 GPS 좌표다.
    let coordinate: CLLocationCoordinate2D
    // 이 지점의 고도다. 실내에서는 층별 보정값으로 쓸 수 있다.
    let altitude: CLLocationDistance
    // 건물 내부 탐험을 위해 층 정보를 따로 가진다.
    let floor: Int
}

// 노드와 노드 사이에 이동 가능한 길이 있음을 나타낸다.
// 단방향 edge로 정의했기 때문에 양방향 이동이 필요하면 반대 방향 edge도 추가해야 한다.
struct GeoObjectARNavEdge: Hashable {
    // 출발 노드 ID다.
    let fromNodeId: String
    // 도착 노드 ID다.
    let toNodeId: String
    // 두 노드 사이 이동 거리다. 길찾기 가중치로 사용할 수 있다.
    let distance: CLLocationDistance
}

// 실내/실외 AR 길찾기용 그래프 자료구조다.
// nodes는 점, edges는 점과 점을 잇는 선이라고 생각하면 된다.
struct GeoObjectARNavGraph {
    // 그래프에 포함된 모든 위치 지점이다.
    let nodes: [GeoObjectARNavNode]
    // 그래프에 포함된 모든 이동 가능한 연결 관계다.
    let edges: [GeoObjectARNavEdge]

    // ID로 특정 노드를 찾는다.
    func node(id: String) -> GeoObjectARNavNode? {
        nodes.first { $0.id == id }
    }

    // 특정 노드에서 바로 이동 가능한 다음 노드 목록을 구한다.
    func neighbors(of nodeId: String) -> [GeoObjectARNavNode] {
        edges.compactMap { edge in
            guard edge.fromNodeId == nodeId else { return nil }
            return node(id: edge.toNodeId)
        }
    }
}
