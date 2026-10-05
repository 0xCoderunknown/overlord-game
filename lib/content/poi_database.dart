class POIDatabase {
  static const List<Map<String, dynamic>> locations = [
    // --- TIER 1 (Common, Low Hazard) ---
    {
      "id": "poi_kindergarten",
      "name": "Abandoned Kindergarten",
      "tier": 1,
      "imagePath": "assets/images/poi/kindergarten.png",
      "flavorText":
          "Small chairs, faded wall drawings. Smells like old dust and decay. Mostly stripped clean.",
    },
    {
      "id": "poi_gas_station",
      "name": "Rusted Gas Station",
      "tier": 1,
      "imagePath": "assets/images/poi/gas_station.png",
      "flavorText":
          "The pumps ran dry decades ago, but the convenience store shelves might still hide forgotten scraps.",
    },

    // --- TIER 2 (Uncommon, Moderate Hazard) ---
    {
      "id": "poi_subway",
      "name": "Collapsed Subway Tunnel",
      "tier": 2,
      "imagePath": "assets/images/poi/subway.png",
      "flavorText":
          "Pitch black. The echo of dripping water makes it impossible to hear what might be creeping up behind you.",
    },

    // --- TIER 3 (Rare, High Hazard) ---
    {
      "id": "poi_hospital",
      "name": "Ruined City Hospital",
      "tier": 3,
      "imagePath": "assets/images/poi/hospital.png",
      "flavorText":
          "Overturned gurneys blockade the hallways. The air is thick, and the triage center looks like a warzone.",
    },

    // --- TIER 4 (Very Rare, Extreme Hazard) ---
    {
      "id": "poi_ami",
      "name": "Abandoned Military Installation (AMI)",
      "tier": 4,
      "imagePath": "assets/images/poi/ami.png",
      "flavorText":
          "Heavy blast doors have been forced open... from the inside. Severe caution advised.",
    },
  ];
}
