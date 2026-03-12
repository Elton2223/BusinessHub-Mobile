import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/filter_settings_model.dart';
import '../services/filter_settings_service.dart';

class HubFilterSettingsScreen extends StatefulWidget {
  const HubFilterSettingsScreen({super.key});

  static String routePath = '/hub-filters';

  @override
  State<HubFilterSettingsScreen> createState() => _HubFilterSettingsScreenState();
}

class _HubFilterSettingsScreenState extends State<HubFilterSettingsScreen> {
  late double _locationRangeKm;
  late List<String> _areaNames;
  late List<String> _categories;
  late bool _ongoingOnly;
  late bool _availableOnly;
  bool _loading = true;
  bool _saving = false;

  static const List<String> presetAreas = [
    'Johannesburg',
    'Cape Town',
    'Durban',
    'Pretoria',
    'Port Elizabeth',
    'Bloemfontein',
  ];

  static const List<String> presetCategories = [
    'Technology',
    'Services',
    'Education',
    'Construction',
    'Creative',
    'Healthcare',
    'Finance',
    'Business',
    'Marketing',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final s = await FilterSettingsService.load();
    if (mounted) {
      setState(() {
        _locationRangeKm = s.locationRangeKm;
        _areaNames = List.from(s.areaNames);
        _categories = List.from(s.categories);
        _ongoingOnly = s.ongoingOnly;
        _availableOnly = s.availableOnly;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await FilterSettingsService.save(FilterSettingsModel(
      locationRangeKm: _locationRangeKm,
      areaNames: _areaNames,
      categories: _categories,
      ongoingOnly: _ongoingOnly,
      availableOnly: _availableOnly,
    ));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filter settings saved.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hub filters',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location range (km)',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          Slider(
                            value: _locationRangeKm.clamp(1.0, 200.0),
                            min: 1,
                            max: 200,
                            divisions: 199,
                            label: '${_locationRangeKm.round()} km',
                            onChanged: (v) => setState(() => _locationRangeKm = v),
                          ),
                          Text(
                            '${_locationRangeKm.round()} km',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChipSection(
                    'Filter by area (city)',
                    presetAreas,
                    _areaNames,
                    (name) {
                      setState(() {
                        if (_areaNames.contains(name)) {
                          _areaNames.remove(name);
                        } else {
                          _areaNames.add(name);
                        }
                      });
                    },
                    isTablet,
                  ),
                  const SizedBox(height: 16),
                  _buildChipSection(
                    'Filter by hub category',
                    presetCategories,
                    _categories,
                    (name) {
                      setState(() {
                        if (_categories.contains(name)) {
                          _categories.remove(name);
                        } else {
                          _categories.add(name);
                        }
                      });
                    },
                    isTablet,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            'Only show available hubs',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text('Hide in-progress and completed'),
                          value: _availableOnly,
                          onChanged: (v) => setState(() => _availableOnly = v),
                        ),
                        SwitchListTile(
                          title: Text(
                            'Only show ongoing hubs',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text('In progress only'),
                          value: _ongoingOnly,
                          onChanged: (v) => setState(() => _ongoingOnly = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Save filters',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChipSection(
    String title,
    List<String> options,
    List<String> selected,
    ValueChanged<String> onTap,
    bool isTablet,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((name) {
                final isSelected = selected.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => onTap(name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
