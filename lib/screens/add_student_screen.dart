import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tutoring_management/model/student_provider.dart';
import '../model/student.dart';

class AddStudentScreen extends StatefulWidget {
  final Student? student;

  const AddStudentScreen({Key? key, this.student}) : super(key: key);

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _id = -1;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _id = widget.student!.id;
      _nameController.text = widget.student!.name;
      _priceController.text = widget.student!.pricePerHour.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      final price = Decimal.parse(
        _priceController.text.replaceAll(',', '.'),
      );

      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final student = Student(
        id: _id == -1 ? null : _id,
        name: _nameController.text,
        pricePerHour: price,
      );
      studentProvider.addOrUpdate(student);
    }
  }

  void _deleteStudent() {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    studentProvider.delete(_id);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle:
            Text(widget.student != null ? 'Edit Student' : 'Add New Student'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            _saveStudent();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(children: [
            Expanded(
              child: CupertinoFormSection.insetGrouped(
                header: const Text('Student'),
                children: [
                  _buildNameRow(),
                  _buildPriceRow(),
                ],
              ),
            ),
            _buildDeleteButton(),
          ]),
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return CupertinoTextFormFieldRow(
      prefix: const Text('Name'),
      placeholder: 'Enter student\'s name',
      controller: _nameController,
      validator: (value) =>
          value?.trim().isEmpty ?? true ? 'Name cannot be empty' : null,
      maxLength: 30,
    );
  }

  Widget _buildPriceRow() {
    return CupertinoTextFormFieldRow(
      prefix: const Text('Price per hour'),
      placeholder: '0,00',
      controller: _priceController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter price';

        final normalized = value.replaceAll(',', '.');

        if (Decimal.tryParse(normalized) == null) {
          return 'Invalid number';
        }

        return null;
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          final cleanValue = value.replaceAll(',', '.');
          _priceController.text = cleanValue;
        }
      },
    );
  }

  Widget _buildDeleteButton() {
    return CupertinoButton(
      onPressed: () async {
        final bool? confirmed = await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Delete student'),
              content: const Text('Are you sure you want to delete this student? This action cannot be undone.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('No'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          _deleteStudent();
          Navigator.of(context).pop();
        }
      },
      child: const Text(
        'Delete',
        style: TextStyle(color: CupertinoColors.destructiveRed),
      ),
    );
  }
}
