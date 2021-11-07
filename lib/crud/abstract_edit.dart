import 'dart:async';

import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_consumer.dart';
import 'package:folly_fields/crud/abstract_edit_content.dart';
import 'package:folly_fields/crud/abstract_edit_controller.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:folly_fields/crud/abstract_route.dart';
import 'package:folly_fields/crud/abstract_ui_builder.dart';
import 'package:folly_fields/crud/empty_edit_controller.dart';
import 'package:folly_fields/folly_fields.dart';
import 'package:folly_fields/responsive/responsive_grid.dart';
import 'package:folly_fields/util/icon_helper.dart';
import 'package:folly_fields/util/safe_future_builder.dart';
import 'package:folly_fields/widgets/circular_waiting.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';
import 'package:folly_fields/widgets/waiting_message.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///
///
///
abstract class AbstractEdit<
        T extends AbstractModel<Object>,
        UI extends AbstractUIBuilder<T>,
        C extends AbstractConsumer<T>,
        E extends AbstractEditController<T>> extends StatefulWidget
    implements AbstractEditContent<T, E> {
  final T model;
  final UI uiBuilder;
  final C consumer;
  final bool edit;
  final E? editController;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final List<AbstractRoute> actionRoutes;

  ///
  ///
  ///
  const AbstractEdit(
    this.model,
    this.uiBuilder,
    this.consumer,
    this.edit, {
    Key? key,
    this.editController,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.actionRoutes = const <AbstractRoute>[],
  }) : super(key: key);

  ///
  ///
  ///
  @override
  AbstractEditState<T, UI, C, E> createState() =>
      AbstractEditState<T, UI, C, E>();
}

///
///
///
class AbstractEditState<
        T extends AbstractModel<Object>,
        UI extends AbstractUIBuilder<T>,
        C extends AbstractConsumer<T>,
        E extends AbstractEditController<T>>
    extends State<AbstractEdit<T, UI, C, E>>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final StreamController<bool> _controller = StreamController<bool>();

  late T _model;
  int _initialHash = 0;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ///
  ///
  ///
  Future<void> _loadData() async {
    try {
      bool exists = true;
      if (widget.model.id == null || widget.consumer.routeName.isEmpty) {
        _model = widget.consumer.fromJson(widget.model.toMap());
      } else {
        _model = await widget.consumer.getById(context, widget.model);
      }

      await widget.editController?.init(context, _model);

      _controller.add(exists);

      _initialHash = _model.hashCode;
    } catch (error, stack) {
      _controller.addError(error, stack);
    }
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.uiBuilder.getSuperSingle()),
        actions: <Widget>[
          if (widget.edit)
            IconButton(
              tooltip: 'Salvar',
              icon: FaIcon(
                widget.consumer.routeName.isEmpty
                    ? FontAwesomeIcons.check
                    : FontAwesomeIcons.solidSave,
              ),
              onPressed: _save,
            ),

          // TODO(anyone): Transform to dropdown menu
          ...widget.actionRoutes
              .asMap()
              .map(
                (int index, AbstractRoute route) => MapEntry<int, Widget>(
                  index,
                  // TODO(anyone): Create an Action Route component.
                  SafeFutureBuilder<ConsumerPermission>(
                    future: widget.consumer.checkPermission(
                      context,
                      route.routeName,
                    ),
                    onWait: (_, __) => const SizedBox(width: 0, height: 0),
                    onError: (_, __, ___) =>
                        const SizedBox(width: 0, height: 0),
                    builder: (
                      BuildContext context,
                      ConsumerPermission permission,
                    ) =>
                        permission.view
                            ? IconButton(
                                tooltip: permission.name,
                                icon: IconHelper.faIcon(permission.iconName),
                                onPressed: () async {
                                  dynamic close =
                                      await Navigator.of(context).pushNamed(
                                    route.path,
                                    arguments: _model,
                                  );

                                  if (close is bool && close) {
                                    _initialHash = _model.hashCode;
                                    Navigator.of(context).pop();
                                  }
                                },
                              )
                            : const SizedBox(width: 0, height: 0),
                  ),
                ),
              )
              .values
              .toList(),
        ],
      ),
      bottomNavigationBar: widget.uiBuilder.buildBottomNavigationBar(context),
      body: widget.uiBuilder.buildBackgroundContainer(
        context,
        Form(
          key: _formKey,
          onWillPop: () async {
            if (!widget.edit) {
              return true;
            }

            _formKey.currentState!.save();
            int currentHash = _model.hashCode;

            bool go = true;
            if (_initialHash != currentHash) {
              go = await FollyDialogs.yesNoDialog(
                context: context,
                message: 'Modificações foram realizadas.\n\n'
                    'Deseja sair mesmo assim?',
              );
            }
            return go;
          },
          child: StreamBuilder<bool>(
            stream: _controller.stream,
            builder: (
              BuildContext context,
              AsyncSnapshot<bool> snapshot,
            ) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ResponsiveGrid(
                    rowCrossAxisAlignment: widget.rowCrossAxisAlignment,
                    children: widget.formContent(
                      context,
                      _model,
                      widget.edit,
                      widget.uiBuilder.labelPrefix,
                      _controller.add,
                      widget.editController ?? (EmptyEditController<T>() as E),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                if (FollyFields().isDebug) {
                  // ignore: avoid_print
                  print('${snapshot.error}\n${snapshot.stackTrace}');
                }

                return Center(
                  child: Text(
                    'Ocorreu um erro:\n'
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return const WaitingMessage(message: 'Consultando...');
            },
          ),
        ),
      ),
    );
  }

  ///
  ///
  ///
  Future<void> _save() async {
    CircularWaiting wait = CircularWaiting(context);

    try {
      wait.show();

      _formKey.currentState!.save();

      if (widget.editController != null) {
        bool validated = await widget.editController!.validate(context, _model);
        if (!validated) {
          wait.close();
          return;
        }
      }

      if (_formKey.currentState!.validate()) {
        bool ok = false;

        if (widget.consumer.routeName.isNotEmpty) {
          ok = await widget.consumer.beforeSaveOrUpdate(context, _model);
        }

        if (ok) {
          ok = await widget.consumer.saveOrUpdate(context, _model);
        }

        wait.close();

        if (ok) {
          _initialHash = _model.hashCode;
          Navigator.of(context).pop(_model);
        }
      } else {
        wait.close();
      }
    } catch (e, s) {
      wait.close();

      if (FollyFields().isDebug) {
        // ignore: avoid_print
        print('$e\n$s');
      }

      await FollyDialogs.dialogMessage(
        context: context,
        message: 'Ocorreu um erro ao tentar salvar:\n$e',
      );
    }
  }

  ///
  ///
  ///
  @override
  void dispose() {
    widget.editController?.dispose(context);
    _controller.close();
    super.dispose();
  }
}
