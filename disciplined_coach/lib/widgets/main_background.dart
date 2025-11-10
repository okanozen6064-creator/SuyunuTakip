// lib/widgets/main_background.dart
import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';

class MainBackground extends StatelessWidget {
  final Widget child;
  const MainBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Katman 1: Düz Koyu Zemin
        Container(color: const Color(0xFF121212)),

        // Katman 2: Parçacık Efekti (Plexus benzeri)
        Positioned.fill(
          child: ParticlesFly(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            connectDots: true, // Noktaları birleştir (Ağ efekti için kritik)
            numberOfParticles: 50, // Çok yoğun olmasın, dikkat dağıtır
            particleColor: Colors.white.withOpacity(0.1), // Çok silik, rahatsız etmesin
            lineColor: const Color(0xFF00C853).withOpacity(0.05), // Hafif yeşilimsi bağlantılar
            speedOfParticles: 0.5, // Yavaş, sakin bir akış
            isRandomColor: false,
          ),
        ),

        // Katman 3: Asıl İçerik
        SafeArea(child: child),
      ],
    );
  }
}
