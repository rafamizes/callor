import 'package:flutter/material.dart';
import 'package:formdator/formdator.dart';

void main() {
  runApp(const _DemoApp());
}

/// Demo purposes app widget.
///
/// The widget displays a simple registration form in which a user enters an
/// email, a password and password confirmation.
class _DemoApp extends StatelessWidget {
  /// Ctor.
  const _DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple form demo',
      home: SafeArea(
        child: _RegForm(
          title: 'Enter an email, a password and password confirmation',
        ),
      ),
    );
  }
}

/// A simple registration form widget.
class _RegForm extends StatelessWidget {
  /// Ctor.
  _RegForm({required String title, Key? key})
      : _title = title,
        super(key: key);

  final String _title;
  // The input data.
  final Map<String, dynamic> _data = {};
  // The form's mandatory key.
  final _fkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(_title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 500,
            child: Form(
              key: _fkey,
              child: Column(
                children: [
                  _EmailField(onSaved: _saveEmail),
                  _SecretField(label: 'Password', onChanged: _refreshPass),
                  _SecretField(
                    label: 'Password confirmation',
                    onChanged: _refreshConfirm,
                    onSaved: _savePass,
                    extra: Equal(_enteredPass, diff: 'does not match.'),
                  ),
                  _ClearSubmitBar(fkey: _fkey, data: _data),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The current entered password value.
  String _enteredPass() => (_data['pass'] as String?) ?? '';

  /// Refreshes the password value.
  void _refreshPass(String value) => _data['pass'] = value;

  /// Refreshes the password confirmation value.
  void _refreshConfirm(String value) => _data['confirm'] = value;

  void _saveEmail(String? email) {
    if (email != null && email.isNotEmpty) {
      _data['email'] = email;
    }
  }

  void _savePass(String? pass) {
    if (pass != null && pass.isNotEmpty) {
      _data['pass'] = pass;
    }
  }
}

/// Callback form onChange event.
typedef OnChanged = void Function(String);

/// Callback for onSave event.
typedef OnSaved = void Function(String?);

/// Convenient form field for sensitive data.
class _SecretField extends StatelessWidget {
  /// A form field that is suitable for entering sensitive data.
  ///
  /// [label] a descriptive text for the field.
  /// [onChange] the callback for data chage event.
  /// [onSaved] the callback for data saved event.
  /// [extra] an optional extra validation step.
  _SecretField({
    required String label,
    OnChanged? onChanged,
    OnSaved? onSaved,
    ValStr? extra,
    Key? key,
  })  : _label = label,
        _onChanged = onChanged,
        _onSaved = onSaved,
        _extra = extra ?? const Ok().call, // a dummy validator as default
        super(key: key);

  final String _label;
  final OnChanged? _onChanged;
  final OnSaved? _onSaved;
  final ValStr _extra;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: _onSaved,
      onChanged: _onChanged,
      validator: Req.val(
        Pair(
          Len.range(4, 8, short: 'at least 4 chars', long: 'at most 8 chars'),
          _extra,
        ),
      ),
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: _label,
        filled: true,
        icon: const Icon(Icons.password),
        hintText: '4 to 8 characters',
      ),
    );
  }
}

/// Email field widget — it trims and validates an email so that it is neither
/// blank nor malformed.
class _EmailField extends StatelessWidget {
  /// Non-blank well-formed email with an optional [extra] validation step.
  ///
  /// [onSaved] callback for email saved event.
  const _EmailField({OnSaved? onSaved, Key? key})
      : _onSaved = onSaved,
        super(key: key);

  final OnSaved? _onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: _onSaved,
      validator: Trim(Req.str(Email.len(50))),
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        filled: true,
        icon: Icon(Icons.email),
        hintText: 'a_user@aprovider.com',
      ),
    );
  }
}

/// A clear and submit buttons within a Row widget.
class _ClearSubmitBar extends StatelessWidget {
  /// Encapsulates the form state.
  const _ClearSubmitBar({
    required GlobalKey<FormState> fkey,
    required Map<String, dynamic> data,
    Key? key,
  })  : _fkey = fkey,
        _data = data,
        super(key: key);

  final GlobalKey<FormState> _fkey;
  final Map<String, dynamic> _data;

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: <Widget>[
        TextButton(
          onPressed: () {
            _data.clear();
            _fkey.currentState?.reset();
          },
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_fkey.currentState?.validate() ?? false) {
              _fkey.currentState?.save();
              _showDialog(context);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  /// Displays a success dialog.
  void _showDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your information has been submitted.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Ok'),
            child: const Text('Thanks'),
          ),
        ],
      ),
    );
  }
}
