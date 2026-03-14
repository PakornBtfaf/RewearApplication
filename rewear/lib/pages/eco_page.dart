import 'package:flutter/material.dart';

class EcoPage extends StatelessWidget {
  const EcoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const int level = 3;
    const double progress = 0.30;
    const int currentXP = 3;
    const int maxXP = 10;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Your Eco Impact', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Eco Level Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Eco Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Icon(Icons.eco, color: Colors.green.shade600),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$level', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      Text('Starter', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Container(height: 16, width: double.infinity, color: Colors.grey.shade200),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(height: 16, color: const Color(0xFF2D7A4F)),
                        ),
                        const SizedBox(
                          height: 16,
                          child: Center(
                            child: Text('30%', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('$currentXP / $maxXP', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ecoCard(Icons.recycling, 'Items Reused', '$currentXP items', Colors.green),
            const SizedBox(height: 12),
            _ecoCard(Icons.water_drop, 'Water Saved', '${currentXP * 2700} liters', Colors.blue),
            const SizedBox(height: 12),
            _ecoCard(Icons.co2, 'CO₂ Reduced', '${(currentXP * 2.1).toStringAsFixed(1)} kg', Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _ecoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
