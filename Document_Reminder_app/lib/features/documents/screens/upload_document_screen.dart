// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import '../../../core/services/token_storage.dart';
// import '../../../core/services/document_service.dart';
// import '../../../core/providers/task_provider.dart';
// import '../../../core/providers/document_provider.dart';
// import '../../../widgets/custom_button.dart';

// class UploadDocumentScreen extends StatefulWidget {
//   const UploadDocumentScreen({super.key});

//   @override
//   State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
// }

// class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
//   String? _selectedFilePath;
//   String? _selectedFileName;
//   bool _isUploading = false;
//   double _uploadProgress = 0.0;

//   Future<void> _pickFile() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.any,
//         allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png', 'xlsx'],
//       );

//       if (result != null && result.files.isNotEmpty) {
//         setState(() {
//           _selectedFilePath = result.files.first.path;
//           _selectedFileName = result.files.first.name;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
//       }
//     }
//   }

//   Future<void> _handleUpload() async {
//     if (_selectedFilePath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a file first')),
//       );
//       return;
//     }

//     // Get selected task
//     final taskProvider = context.read<TaskProvider>();
//     if (taskProvider.selectedTaskId == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select a task first')),
//         );
//       }
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//       _uploadProgress = 0.0;
//     });

//     try {
//       final userId = await TokenStorage.getUserId();

//       if (userId == null) {
//         throw Exception('User ID not found');
//       }

//       final documentService = DocumentService();
//       final result = await documentService.uploadDocument(
//         filePath: _selectedFilePath!,
//         taskId: taskProvider.selectedTaskId!,
//         userId: userId,
//         onProgress: (sent, total) {
//           setState(() {
//             _uploadProgress = sent / total;
//           });
//         },
//       );

//       if (result['success'] && mounted) {
//         // Refresh documents list
//         context.read<DocumentProvider>().loadDocuments();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               result['message'] ?? 'Document uploaded successfully',
//             ),
//           ),
//         );
//         Navigator.pop(context);
//       } else if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(result['message'] ?? 'Upload failed')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error uploading document: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Upload Document')),
//         body: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Select Document',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 24),
//               // Task selector
//               Consumer<TaskProvider>(
//                 builder: (context, taskProvider, child) {
//                   return DropdownButtonFormField<String?>(
//                     value: taskProvider.selectedTaskId,
//                     decoration: InputDecoration(
//                       labelText: 'Select Task',
//                       prefixIcon: const Icon(Icons.assignment),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     items: taskProvider.tasks.map((task) {
//                       return DropdownMenuItem(
//                         value: task.id,
//                         child: Text(task.title),
//                       );
//                     }).toList(),
//                     onChanged: (taskId) {
//                       taskProvider.setSelectedTaskId(taskId);
//                     },
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),

//               // File Picker Button
//               OutlinedButton.icon(
//                 onPressed: _isUploading ? null : _pickFile,
//                 icon: const Icon(Icons.attach_file),
//                 label: const Text('Choose File'),
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 56),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Preview Section
//               if (_selectedFileName != null) ...[
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFE2E8F0)),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(
//                         Icons.picture_as_pdf,
//                         size: 64,
//                         color: Color(0xFFEF4444),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         _selectedFileName!,
//                         style: Theme.of(context).textTheme.titleMedium,
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 8),
//                       if (_isUploading) ...[
//                         const SizedBox(height: 16),
//                         LinearProgressIndicator(
//                           value: _uploadProgress,
//                           minHeight: 8,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '${(_uploadProgress * 100).toStringAsFixed(0)}% uploaded',
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                       ] else
//                         Text(
//                           'Ready to upload',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],

//               const Spacer(),

//               // Upload Button
//               CustomButton(
//                 text: _isUploading
//                     ? 'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%'
//                     : 'Upload Document',
//                 onPressed: _isUploading ? () {} : () => _handleUpload(),
//                 icon: Icons.cloud_upload_outlined,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//-------------------------------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/services/token_storage.dart';
// import '../../../core/services/document_service.dart'; // Removed
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/document_provider.dart';
import '../../../widgets/custom_button.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  String? _selectedFilePath; // Mobile/Desktop
  List<int>? _selectedFileBytes; // Web
  String? _selectedFileName;

  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: kIsWeb, // IMPORTANT for web
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        setState(() {
          _selectedFileName = file.name;
          _selectedFilePath = file.path; // null on web
          _selectedFileBytes = file.bytes; // non-null on web if withData: true
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    if (taskProvider.selectedTaskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a task first')),
      );
      return;
    }

    // Check that we have a file (bytes for web, path for mobile/desktop)
    if (_selectedFilePath == null && _selectedFileBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File data not available')));
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      if (!mounted) return;

      final documentProvider = context.read<DocumentProvider>();
      final success = await documentProvider.uploadDocument(
        filePath: _selectedFilePath,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
        taskId: taskProvider.selectedTaskId!,
        userId: userId,
        // DocumentProvider's uploadDocument doesn't currently expose onProgress in its signature
        // in the implementation I saw earlier, but if it did, we'd pass it.
        // Checking DocumentProvider signature from earlier view:
        // Future<bool> uploadDocument({..., void Function(int, int)? onProgress})
        onProgress: (sent, total) {
          if (total > 0) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload successful')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(documentProvider.errorMessage ?? 'Upload failed'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Task selector
            Consumer<TaskProvider>(
              builder: (_, taskProvider, _) {
                return DropdownButtonFormField<String?>(
                  value: taskProvider.selectedTaskId,
                  decoration: InputDecoration(
                    labelText: 'Select Task',
                    prefixIcon: const Icon(Icons.assignment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: taskProvider.tasks.map((task) {
                    return DropdownMenuItem(
                      value: task.id,
                      child: Text(task.title),
                    );
                  }).toList(),
                  onChanged: taskProvider.setSelectedTaskId,
                );
              },
            ),

            const SizedBox(height: 24),

            /// File picker
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),

            const SizedBox(height: 24),

            if (_selectedFileName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    if (_isUploading) ...[
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 8),
                      Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                    ],
                  ],
                ),
              ),

            const Spacer(),

            CustomButton(
              text: _isUploading ? 'Uploading...' : 'Upload Document',
              icon: Icons.cloud_upload_outlined,
              onPressed: _isUploading ? () {} : () => _handleUpload(),
            ),
          ],
        ),
      ),
    );
  }
}
