import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../content/poi_database.dart';
import '../../engine/game_manager.dart';
import '../models/game_models.dart';

class EventModal extends StatefulWidget {
  final Scavenger scavenger;

  const EventModal({super.key, required this.scavenger});

  @override
  State<EventModal> createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late Map<String, dynamic> selectedPoi;

  @override
  void initState() {
    super.initState();
    // THE FIX: Directly read what the Engine saved to memory!
    String targetId =
        widget.scavenger.pendingPoiId ?? POIDatabase.locations.first['id'];
    selectedPoi = POIDatabase.locations.firstWhere(
      (poi) => poi['id'] == targetId,
      orElse: () => POIDatabase.locations.first,
    );
  }

  Color _getRiskColor(int tier) {
    switch (tier) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.yellowAccent;
      case 3:
        return Colors.orangeAccent;
      case 4:
        return Colors.redAccent;
      default:
        return Colors.green;
    }
  }

  String _getRiskLabel(int tier) {
    switch (tier) {
      case 1:
        return "MINIMAL";
      case 2:
        return "MODERATE";
      case 3:
        return "SEVERE";
      case 4:
        return "EXTREME";
      default:
        return "UNKNOWN";
    }
  }

  @override
  Widget build(BuildContext context) {
    int tier = selectedPoi['tier'];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              selectedPoi['name'].toString().toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 1),
                color: Colors.black,
              ),
              child: Image.asset(
                selectedPoi['imagePath'],
                fit: BoxFit.cover,
                color: Colors.greenAccent,
                colorBlendMode: BlendMode.modulate,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "HAZARD LEVEL:",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  "[ ${_getRiskLabel(tier)} ]",
                  style: TextStyle(
                    color: _getRiskColor(tier),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "> ${selectedPoi['flavorText']}",
              style: TextStyle(
                color: Colors.green.shade300,
                fontFamily: 'monospace',
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<GameManager>().resolveManualEncounter(
                        widget.scavenger,
                        false,
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.orangeAccent,
                        width: 2,
                      ),
                      foregroundColor: Colors.orangeAccent,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      "[ BYPASS ]",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<GameManager>().resolveManualEncounter(
                        widget.scavenger,
                        true,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      side: BorderSide(color: _getRiskColor(tier), width: 2),
                      foregroundColor: _getRiskColor(tier),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      "[ BREACH ]",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
