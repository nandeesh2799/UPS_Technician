import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Use current location',
                    onPressed: _getCurrentLocation,
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
