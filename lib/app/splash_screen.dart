import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/scanflow_logo.dart';

/// Short branded handoff from Android's native launch screen into the library.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _entrance,
    curve: Curves.easeOut,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: .88,
    end: 1,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack));
  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    _handoff = Timer(const Duration(milliseconds: 1750), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: const Color(0xff10283b),
      systemNavigationBarColor: const Color(0xff10283b),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff10283b),
                  Color(0xff0d4c50),
                  Color(0xff087f72),
                ],
                stops: [0, .58, 1],
              ),
            ),
          ),
          const Positioned(
            top: -100,
            right: -80,
            child: _GlowOrb(size: 280, color: Color(0xff47d9bd)),
          ),
          const Positioned(
            bottom: -130,
            left: -95,
            child: _GlowOrb(size: 320, color: Color(0xff1a9c8a)),
          ),
          Positioned(
            right: -82,
            bottom: -30,
            child: Opacity(
              opacity: .075,
              child: Transform.rotate(
                angle: -.14,
                child: const ScanFlowLogo(size: 340, onDark: true),
              ),
            ),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _entrance,
              builder: (context, child) => Opacity(
                opacity: _opacity.value,
                child: Transform.scale(scale: _scale.value, child: child),
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const ScanFlowLogo(size: 120, onDark: true),
                  const SizedBox(height: 25),
                  const Text(
                    'ScanFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.8,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Scan. Organize. Share.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .76),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .25,
                    ),
                  ),
                  const Spacer(flex: 3),
                  const _LoadingIndicator(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: .16), color.withValues(alpha: 0)],
        ),
      ),
    ),
  );
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final phase = (_controller.value - index * .18) % 1;
        final emphasis = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
        return Container(
          width: 6 + 2 * emphasis,
          height: 6 + 2 * emphasis,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.white.withValues(alpha: .35),
              const Color(0xff83f2d7),
              emphasis,
            ),
            shape: BoxShape.circle,
          ),
        );
      }),
    ),
  );
}
