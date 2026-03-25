import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Snake Physics Logic Tests', () {
    test('Loop (Slučka) Mode Math Verification', () {
      // fract(time) should keep values between 0.0 and 1.0
      double time = 0.5;
      expect(time % 1.0, 0.5);
      
      time = 1.2;
      expect(time % 1.0, closeTo(0.2, 0.0001));
      
      time = -0.3;
      expect((time % 1.0 + 1.0) % 1.0, closeTo(0.7, 0.0001));
    });

    test('Ping-Pong Mode Math Verification', () {
      // 1.0 - abs(mod(time, 2.0) - 1.0)
      double pingPong(double t) {
        return 1.0 - ( (t % 2.0) - 1.0 ).abs();
      }

      expect(pingPong(0.0), 0.0);
      expect(pingPong(0.5), 0.5);
      expect(pingPong(1.0), 1.0);
      expect(pingPong(1.5), 0.5);
      expect(pingPong(2.0), 0.0);
      expect(pingPong(2.5), 0.5);
    });

    test('Turbo Mode Math Verification', () {
      // Exponential speed: speed = speed * (1.0 + acc)
      double calculateTurboPos(double time, double acc) {
        // Simplified model: position accelerates over time
        // s = v0*t + 0.5*a*t^2
        return (time + 0.5 * acc * time * time) % 1.0;
      }

      expect(calculateTurboPos(0.5, 0.0), 0.5); // No acceleration
      expect(calculateTurboPos(0.5, 0.1), greaterThan(0.5)); // With acceleration
      expect(calculateTurboPos(10.0, 0.5), inInclusiveRange(0.0, 1.0)); // Should still loop
    });
  });
}
