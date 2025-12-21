import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/roadmap_item_model.dart';

class RoadmapView extends StatefulWidget {
  const RoadmapView({super.key});

  @override
  State<RoadmapView> createState() => _RoadmapViewState();
}

class _RoadmapViewState extends State<RoadmapView> {
  final List<RoadmapItemModel> _items = RoadmapItemModel.generateHSK1Items();
  final int _currentPandaIndex = 5; // Panda is at item 6 (index 5)

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F7), // Light background
      child: Column(
        children: [
          // Custom Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
            ),
            color: Colors.white,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              "HSK 1 Roadmap",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                // Snake pattern: 0: center, 1: right, 2: center, 3: left, 4: center...
                // Or simple zig-zag: even left, odd right?
                // Let's do a simple vertical timeline for clarity and robustness first,
                // but user asked for "Roadmap", so let's try a simple alternating visual.

                return _buildRoadmapItem(item, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapItem(RoadmapItemModel item, int index) {
    final isPandaHere = index == _currentPandaIndex;
    final isLeft = index % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (!isLeft) const Spacer(),
          _buildNode(item, isPandaHere),
          if (isLeft) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildNode(RoadmapItemModel item, bool isPandaHere) {
    return Column(
      children: [
        if (isPandaHere) _buildPanda(),
        GestureDetector(
          onTap: () {
            // Handle tap
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Selected: ${item.title}")));
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: item.isLocked
                  ? Colors.grey.shade300
                  : (item.isCompleted ? AppColors.primaryBrand : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(
                color: item.isLocked ? Colors.grey : AppColors.primaryBrand,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: item.isLocked
                ? const Icon(Icons.lock, color: Colors.grey)
                : Text(
                    "${item.id}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: item.isCompleted
                          ? Colors.white
                          : AppColors.primaryBrand,
                    ),
                  ),
          ),
        ),
        if (isPandaHere)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              item.description,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildPanda() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      height: 60,
      width: 60,
      // Placeholder for Panda Image
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Use Icon as placeholder since generation failed
          const Icon(Icons.pets, size: 32, color: Colors.black),
          Positioned(
            bottom: 0,
            child: Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.all(Radius.elliptical(40, 10)),
              ),
            ), // Shadow
          ),
        ],
      ),
    );
  }
}
