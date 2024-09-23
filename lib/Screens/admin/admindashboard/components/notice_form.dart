import 'package:eskool/Screens/admin/components/custon_button.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/responsive.dart';
import '../../components/custom_page_layout.dart';

import 'calenderWidget.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class NoticeForm extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final List<PlatformFile>? initialFiles;
  final Function(String title, String description, List<PlatformFile>? files)
      onSubmit;

  const NoticeForm({
    Key? key,
    this.initialTitle,
    this.initialDescription,
    this.initialFiles,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _NoticeFormState createState() => _NoticeFormState();
}

class _NoticeFormState extends State<NoticeForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<PlatformFile>? _mediaFiles;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _mediaFiles = widget.initialFiles ?? [];
  }

  Future<void> _pickMediaFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _mediaFiles = result.files;
      });
    }
  }

  void _clearFields() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _mediaFiles = null;
    });
  }

  void _removeFile(int index) {
    setState(() {
      _mediaFiles!.removeAt(index);
    });
  }

  Future<void> _submitToBackend(
      String title, String description, PlatformFile? file) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.18.121:3000/api/notices'));

      // Add title and description fields
      request.fields['title'] = title;
      request.fields['description'] = description;

      // Add the single file if it's not null
      if (file != null) {
        // Determine content type based on file extension
        String mimeType = '';
        if (file.extension == 'png') {
          mimeType = 'image/png';
        } else if (file.extension == 'jpg' || file.extension == 'jpeg') {
          mimeType = 'image/jpeg';
        } else if (file.extension == 'pdf') {
          mimeType = 'application/pdf';
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // 'file' should match the key used in your backend
            file.bytes!, // Use the bytes property for web
            filename: file.name,
            contentType: MediaType.parse(mimeType), // Use the MediaType
          ),
        );
      }

      // Send the request to the server
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 201) {
        print('Notice created successfully');
      } else {
        var responseBody = await response.stream.bytesToString();
        print(
            'Failed to submit notice: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error submitting notice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageLayout(
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(appPadding),
              margin: EdgeInsets.all(appPadding),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initialTitle == null ? "Create a Post" : "Edit Post",
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    label: "Select files",
                    color: Colors.blue.shade100,
                    onPressed: _pickMediaFiles,
                  ),
                  if (_mediaFiles != null) ...[
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _mediaFiles!.length,
                      itemBuilder: (context, index) {
                        final file = _mediaFiles![index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(file.extension == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.image),
                          title: Text(file.name),
                          trailing: IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeFile(index),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 20),
                  Row(
                    children: [
                      CustomButton(
                        label: "Submit",
                        color: Colors.green.shade200,
                        onPressed: () {
                          _submitToBackend(
                            _titleController.text,
                            _descriptionController.text,
                            _mediaFiles != null && _mediaFiles!.isNotEmpty
                                ? _mediaFiles![0]
                                : null,
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      CustomButton(
                        label: "Clear",
                        color: Colors.red.shade200,
                        onPressed: _clearFields,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    label: "Cancel",
                    color: Colors.grey.shade300,
                    onPressed: () => Navigator.pop(
                        context), // Navigates back to the previous page
                  ),
                ],
              ),
            ),
          ),
          if (!Responsive.isMobile(context))
            Expanded(flex: 2, child: CalenderWidget())
        ],
      ),
    );
  }
}