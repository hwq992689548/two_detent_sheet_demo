import 'package:flutter/material.dart';

/// A nearby place shown in the long-list demo sheet.
class NearbyPlace {
  const NearbyPlace({
    required this.name,
    required this.address,
    required this.distance,
    required this.icon,
    required this.color,
  });

  final String name;
  final String address;
  final String distance;
  final IconData icon;
  final Color color;
}

const List<NearbyPlace> kNearbyPlaces = <NearbyPlace>[
  NearbyPlace(
    name: '云朵咖啡',
    address: '南京西路 88 号 · 1F',
    distance: '120 m',
    icon: Icons.local_cafe_outlined,
    color: Color(0xFFB07A45),
  ),
  NearbyPlace(
    name: '静安寺地铁站',
    address: '2 号线 / 7 号线 · 3 号口',
    distance: '260 m',
    icon: Icons.directions_subway_outlined,
    color: Color(0xFF3A7BD5),
  ),
  NearbyPlace(
    name: '人民公园',
    address: '南京西路 231 号',
    distance: '380 m',
    icon: Icons.park_outlined,
    color: Color(0xFF4C9A5F),
  ),
  NearbyPlace(
    name: '城市书店',
    address: '愚园路 156 号 · 2F',
    distance: '450 m',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF8E6BB5),
  ),
  NearbyPlace(
    name: '老城面馆',
    address: '万航渡路 42 号',
    distance: '520 m',
    icon: Icons.ramen_dining_outlined,
    color: Color(0xFFC9743A),
  ),
  NearbyPlace(
    name: '中央停车场',
    address: '静安嘉里中心 B2',
    distance: '610 m',
    icon: Icons.local_parking_outlined,
    color: Color(0xFF4F7CAC),
  ),
  NearbyPlace(
    name: '星光影城',
    address: '南京西路 1515 号 · 6F',
    distance: '690 m',
    icon: Icons.movie_outlined,
    color: Color(0xFFB65A7A),
  ),
  NearbyPlace(
    name: '绿意花店',
    address: '胶州路 88 号',
    distance: '740 m',
    icon: Icons.local_florist_outlined,
    color: Color(0xFF5F9E88),
  ),
  NearbyPlace(
    name: '健身工坊',
    address: '常德路 800 号 · B1',
    distance: '820 m',
    icon: Icons.fitness_center_outlined,
    color: Color(0xFF6E7BB5),
  ),
  NearbyPlace(
    name: '河畔步道',
    address: '苏州河静安段',
    distance: '900 m',
    icon: Icons.directions_walk_outlined,
    color: Color(0xFF4D988F),
  ),
  NearbyPlace(
    name: '静安美术馆',
    address: '陕西北路 500 号',
    distance: '1.0 km',
    icon: Icons.museum_outlined,
    color: Color(0xFF9A6C4F),
  ),
  NearbyPlace(
    name: '宠物友好医院',
    address: '武定路 980 号',
    distance: '1.1 km',
    icon: Icons.pets_outlined,
    color: Color(0xFFB07A45),
  ),
  NearbyPlace(
    name: '共享单车点',
    address: '愚园支路 12 号',
    distance: '1.2 km',
    icon: Icons.pedal_bike_outlined,
    color: Color(0xFF4C9A5F),
  ),
  NearbyPlace(
    name: '麦香面包房',
    address: '北京西路 1200 号',
    distance: '1.3 km',
    icon: Icons.bakery_dining_outlined,
    color: Color(0xFFC98A3A),
  ),
  NearbyPlace(
    name: '城市银行',
    address: '南京西路 1266 号',
    distance: '1.4 km',
    icon: Icons.account_balance_outlined,
    color: Color(0xFF506E9E),
  ),
  NearbyPlace(
    name: '小树苗幼儿园',
    address: '新闸路 1888 号',
    distance: '1.5 km',
    icon: Icons.child_care_outlined,
    color: Color(0xFFD08A5A),
  ),
  NearbyPlace(
    name: '静安游泳馆',
    address: '康定路 1500 号',
    distance: '1.7 km',
    icon: Icons.pool_outlined,
    color: Color(0xFF3A90B5),
  ),
  NearbyPlace(
    name: '夜间便利店',
    address: '南京西路 950 号 · 24h',
    distance: '1.8 km',
    icon: Icons.storefront_outlined,
    color: Color(0xFF6B8E5A),
  ),
];
