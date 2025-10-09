// lib/features/post/presentation/widgets/location_field.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/services/geocoding/geocoding_client.dart';
import 'package:travel_app/core/services/geocoding/geocoding_provider.dart';

class LocationField extends ConsumerStatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;

  /// Bir yer seçildiğinde parent’a (opsiyonel) lat/lng de gönderebiliriz
  final void Function({required String label, double? lat, double? lng})? onPlaceSelected;

  const LocationField({
    super.key,
    required this.initial,
    required this.onChanged,
    this.onPlaceSelected,
  });

  @override
  ConsumerState<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends ConsumerState<LocationField> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool _loading = false;
  List<PlaceSuggestion> _results = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String v) {
    widget.onChanged(v);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (v.trim().isEmpty) {
        setState(() => _results = []);
        return;
      }
      setState(() => _loading = true);
      try {
        final client = ref.read(geocodingClientProvider);
        final items = await client.searchPlaces(v, limit: 6, lang: 'en');
        if (mounted) setState(() => _results = items);
      } catch (_) {
        if (mounted) setState(() => _results = []);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  void _selectSuggestion(PlaceSuggestion s) {
    _controller.text = s.displayName;
    widget.onChanged(s.displayName);
    widget.onPlaceSelected?.call(label: s.displayName, lat: s.lat, lng: s.lon);
    setState(() => _results = []);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(8));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            labelText: 'Location (search)',
            border: border,
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_controller.text.isEmpty
                    ? const Icon(Icons.place_outlined)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged('');
                          setState(() => _results = []);
                        },
                      )),
          ),
        ),
        const SizedBox(height: 6),
        if (_results.isNotEmpty)
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = _results[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, size: 20),
                  title: Text(
                    s.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectSuggestion(s),
                );
              },
            ),
          ),
      ],
    );
  }
}
