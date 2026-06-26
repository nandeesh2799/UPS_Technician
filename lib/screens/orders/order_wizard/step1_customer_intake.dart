import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../../../../utils/validators.dart';

class Step1CustomerIntake extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const Step1CustomerIntake({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
  });

  @override
  State<Step1CustomerIntake> createState() => _Step1CustomerIntakeState();
}

class _Step1CustomerIntakeState extends State<Step1CustomerIntake> {
  bool _isLoadingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled. Please enable them.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format the address nicely
        final parts = [
          if (place.name != null && place.name != place.street) place.name,
          if (place.street != null) place.street,
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality,
          if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) place.subAdministrativeArea,
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea,
          if (place.postalCode != null && place.postalCode!.isNotEmpty) place.postalCode,
          if (place.country != null && place.country!.isNotEmpty) place.country,
        ];
        
        final formattedAddress = parts.where((p) => p != null && p.trim().isNotEmpty).join(', ');
        widget.addressController.text = formattedAddress;
      } else {
        widget.addressController.text = "${position.latitude}, ${position.longitude}";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _importFromMapsLink(BuildContext context) async {
    final TextEditingController linkController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Import from Maps Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste any Google Maps link (e.g. https://maps.app.goo.gl/xxx or place details link).',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Google Maps Link',
                  hintText: 'https://maps.app.goo.gl/...',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && linkController.text.trim().isNotEmpty) {
      final link = linkController.text.trim();
      setState(() => _isLoadingLocation = true);
      try {
        String urlToParse = link;
        
        // Follow redirect for short URLs
        if (link.contains('maps.app.goo.gl') || link.contains('goo.gl/maps')) {
          final resolved = await _resolveShortLink(link);
          if (resolved != null) {
            urlToParse = resolved;
          }
        }

        // Parse coordinates from URL
        RegExp latLngRegExp = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
        RegExp qLatLngRegExp = RegExp(r'[?&](?:q|ll|query)=(-?\d+\.\d+),(-?\d+\.\d+)');
        
        final match = latLngRegExp.firstMatch(urlToParse) ?? qLatLngRegExp.firstMatch(urlToParse);
        if (match != null) {
          double lat = double.parse(match.group(1)!);
          double lng = double.parse(match.group(2)!);
          
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            final parts = [
              if (place.name != null && place.name != place.street) place.name,
              if (place.street != null) place.street,
              if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
              if (place.locality != null && place.locality!.isNotEmpty) place.locality,
              if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) place.subAdministrativeArea,
              if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea,
              if (place.postalCode != null && place.postalCode!.isNotEmpty) place.postalCode,
              if (place.country != null && place.country!.isNotEmpty) place.country,
            ];
            final formattedAddress = parts.where((p) => p != null && p.trim().isNotEmpty).join(', ');
            widget.addressController.text = formattedAddress;
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Address imported successfully from Maps link')),
            );
          } else {
            widget.addressController.text = "$lat, $lng";
          }
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Could not extract coordinates from Maps link.')),
          );
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error importing location: $e')),
        );
      } finally {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<String?> _resolveShortLink(String url) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url))..followRedirects = true;
      final response = await client.send(request);
      return response.request?.url.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Customer Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Enter the details of the customer for this service order.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        TextFormField(
          controller: widget.nameController,
          decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person)),
          validator: Validators.required,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: widget.phoneController,
          decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '+91 XXXXX XXXXX'),
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
          onChanged: (value) {
            if (!value.startsWith('+91')) {
              widget.phoneController.text = '+91';
              widget.phoneController.selection = TextSelection.fromPosition(TextPosition(offset: widget.phoneController.text.length));
            }
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: widget.addressController,
          decoration: InputDecoration(
            labelText: 'Complete Address', 
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _isLoadingLocation
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        tooltip: 'Use current location',
                        onPressed: _getCurrentLocation,
                      ),
                      IconButton(
                        icon: const Icon(Icons.link),
                        tooltip: 'Import from Maps link',
                        onPressed: () => _importFromMapsLink(context),
                      ),
                    ],
                  ),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          validator: Validators.required,
        ),
      ],
    );
  }
}
