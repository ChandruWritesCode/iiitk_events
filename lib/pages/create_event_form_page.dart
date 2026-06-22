import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:iiitk_events/constants.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key, this.eventId, this.initialData});
  final String? eventId;
  final Map<String, dynamic>? initialData;

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  // --- CLOUDINARY CONFIG ---

  File? _posterImage;
  String _existingImageUrl = '';
  final ImagePicker _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();

  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  DateTime? _selectedDateObj;
  TimeOfDay? _selectedTimeObj;

  String _selectedCategory = 'Technical';

  @override
  void initState() {
    super.initState();
    // pre-fill
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _titleController.text = data['title'] ?? '';
      _venueController.text = data['venue'] ?? '';
      _descController.text = data['description'] ?? '';
      _linkController.text = data['registrationLink'] ?? '';
      _selectedCategory = data['category'] ?? 'Technical';
      _existingImageUrl = data['imageUrl'] ?? '';

      if (data['eventDate'] != null) {
        DateTime date = (data['eventDate'] as Timestamp).toDate();
        _selectedDateObj = date;
        _selectedTimeObj = TimeOfDay.fromDateTime(date);

        _dateController.text =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedTimeObj != null) {
            _timeController.text = _selectedTimeObj!.format(context);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _descController.dispose();
    _linkController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _posterImage = File(pickedFile.path);
      });
    }
  }

  InputDecoration _customInputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.black,
              surface: const Color(0xFF121212),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateObj = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final theme = Theme.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.black,
              surface: const Color(0xFF121212),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTimeObj = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool hasImage = _posterImage != null || _existingImageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.eventId == null ? 'Post New Event' : 'Edit Event Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasImage
                          ? theme.colorScheme.primary
                          : const Color(0xFF333333),
                      width: hasImage ? 2.0 : 1.0,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _posterImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_posterImage!, fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            const Center(
                              child: Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        )
                      : _existingImageUrl.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: _existingImageUrl,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            const Center(
                              child: Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to Upload Event Poster',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: theme.colorScheme.primary,
                decoration: _customInputDecoration(
                  context,
                  'Event Title (e.g. CP Bootcamp)',
                  Icons.title_rounded,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDecoration(
                        context,
                        '',
                        Icons.category_rounded,
                      ),
                      items: ['Technical', 'Cultural', 'Sports', 'Other'].map((
                        String category,
                      ) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedCategory = newValue);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _venueController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: theme.colorScheme.primary,
                      decoration: _customInputDecoration(
                        context,
                        'Venue / Link',
                        Icons.location_on_rounded,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDecoration(
                        context,
                        'Select Date',
                        Icons.calendar_month_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDecoration(
                        context,
                        'Select Time',
                        Icons.access_time_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _linkController,
                style: const TextStyle(color: Colors.white),
                cursorColor: theme.colorScheme.primary,
                decoration: _customInputDecoration(
                  context,
                  'Registration Form URL',
                  Icons.link_rounded,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                cursorColor: theme.colorScheme.primary,
                maxLines: 5,
                decoration: _customInputDecoration(
                  context,
                  'Event Details & Rules...',
                  Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: () async {
                  if (_titleController.text.trim().isEmpty ||
                      _selectedDateObj == null ||
                      _selectedTimeObj == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill out Title, Date, and Time'),
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    DateTime parsedDate = DateTime(
                      _selectedDateObj!.year,
                      _selectedDateObj!.month,
                      _selectedDateObj!.day,
                      _selectedTimeObj!.hour,
                      _selectedTimeObj!.minute,
                    );

                    final user = FirebaseAuth.instance.currentUser;

                    String finalImageUrl = _existingImageUrl;

                    // IMAGE UPLOAD LOGIC
                    if (_posterImage != null) {
                      final uri = Uri.parse(
                        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
                      );
                      final request = http.MultipartRequest('POST', uri)
                        ..fields['upload_preset'] = cloudinaryUploadPreset
                        ..files.add(
                          await http.MultipartFile.fromPath(
                            'file',
                            _posterImage!.path,
                          ),
                        );

                      final response = await request.send();

                      if (response.statusCode == 200) {
                        final responseData = await response.stream
                            .bytesToString();
                        final jsonMap = json.decode(responseData);
                        finalImageUrl = jsonMap['secure_url'];
                      } else {
                        throw Exception(
                          'Failed to upload image to Cloudinary.',
                        );
                      }
                    }

                    if (widget.eventId != null) {
                      await FirebaseFirestore.instance
                          .collection('events')
                          .doc(widget.eventId)
                          .update({
                            'title': _titleController.text.trim(),
                            'category': _selectedCategory,
                            'venue': _venueController.text.trim(),
                            'description': _descController.text.trim(),
                            'registrationLink': _linkController.text.trim(),
                            'imageUrl': finalImageUrl,
                            'eventDate': Timestamp.fromDate(parsedDate),
                          });
                    } else {
                      await FirebaseFirestore.instance
                          .collection('events')
                          .add({
                            'title': _titleController.text.trim(),
                            'host': user?.displayName ?? 'Unknown Club',
                            'category': _selectedCategory,
                            'venue': _venueController.text.trim(),
                            'description': _descController.text.trim(),
                            'registrationLink': _linkController.text.trim(),
                            'imageUrl': finalImageUrl,
                            'eventDate': Timestamp.fromDate(parsedDate),
                            'createdAt': FieldValue.serverTimestamp(),
                            'creatorId': user?.uid,
                          });
                    }

                    if (context.mounted) {
                      Navigator.pop(context); // pop loading screen
                      Navigator.pop(context); // pop Home Screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.eventId == null
                                ? 'Event Published Successfully!'
                                : 'Event Updated Successfully!',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Pop loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.eventId == null
                      ? 'Publish Event'
                      : 'Update Event Details',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
