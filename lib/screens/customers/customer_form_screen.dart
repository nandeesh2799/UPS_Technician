import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../utils/validators.dart';
import '../../utils/extensions.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91');
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
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
        _addressController.text = formattedAddress;
      } else {
        _addressController.text = "${position.latitude}, ${position.longitude}";
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
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone;
      _addressController.text = widget.customer!.address;
      _emailController.text = widget.customer!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final customer = CustomerModel(
      id: widget.customer?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
      lastOrderDate: widget.customer?.lastOrderDate ?? DateTime.now(),
      totalOrders: widget.customer?.totalOrders ?? 0,
      totalSpend: widget.customer?.totalSpend ?? 0.0,
    );

    try {
      if (widget.customer == null) {
        await context.read<CustomerProvider>().addCustomer(customer);
        if (mounted) context.showSuccessSnackBar('Customer added successfully');
      } else {
        await context.read<CustomerProvider>().updateCustomer(customer);
        if (mounted) context.showSuccessSnackBar('Customer updated successfully');
      }
      if (mounted) Navigator.pop(context, customer);
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed to save customer');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'New Customer' : 'Edit Customer'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                    validator: Validators.required,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email (Optional)', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address', 
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
                    validator: Validators.required,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Customer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
