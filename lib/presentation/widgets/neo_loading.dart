import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class NeoLoading extends StatefulWidget {
  const NeoLoading({super.key});

  @override
  State<NeoLoading> createState() => _NeoLoadingState();
}

class _NeoLoadingState extends State<NeoLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3 kotak yang berdenyut bergantian
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Tiap kotak delay animasinya berbeda
                  final delay = index * 0.2;
                  final value = (_controller.value - delay).clamp(0.0, 1.0);
                  final scale = 0.6 + (value * 0.4);

                  // Warna bergantian: merah, kuning, merah
                  final colors = [
                    AppTheme.primary,
                    AppTheme.yellow,
                    AppTheme.primary,
                  ];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors[index],
                          border: Border.all(
                            color: AppTheme.black,
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 20),
          const Text(
            'LOADING...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}