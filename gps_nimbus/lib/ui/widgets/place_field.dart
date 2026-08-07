import 'package:flutter/material.dart';

import '../../core/places.dart';
import '../../domain/model/geo_point.dart';

/// Champ de saisie d'un lieu, avec suggestions parmi les lieux connus.
///
/// Ce n'est pas encore une recherche d'adresses : le catalogue est court et
/// local. Le champ est conçu pour être remplacé par un vrai géocodeur sans
/// changer l'écran d'accueil.
class PlaceField extends StatefulWidget {
  const PlaceField({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final GeoPoint? selected;
  final ValueChanged<GeoPoint?> onChanged;

  @override
  State<PlaceField> createState() => _PlaceFieldState();
}

class _PlaceFieldState extends State<PlaceField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.selected?.label ?? '',
  );

  @override
  void didUpdateWidget(PlaceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final label = widget.selected?.label ?? '';
    if (label != _controller.text) _controller.text = label;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<GeoPoint>(
      displayStringForOption: (place) => place.label,
      optionsBuilder: (value) => Places.search(value.text),
      onSelected: widget.onChanged,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        // On garde le texte synchronisé avec la sélection du parent.
        if (controller.text.isEmpty && widget.selected != null) {
          controller.text = widget.selected!.label;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Effacer',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      widget.onChanged(null);
                    },
                  ),
          ),
          onChanged: (text) {
            final match = Places.byLabel(text);
            widget.onChanged(match);
          },
          onSubmitted: (_) => onSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Card(
            margin: const EdgeInsets.only(top: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final place = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(place.label),
                    onTap: () => onSelected(place),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
