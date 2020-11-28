import 'package:flutter/cupertino.dart';
import 'package:folly_fields/crud/abstract_model.dart';

///
///
///
abstract class AbstractConsumer<T extends AbstractModel> {
  ///
  ///
  ///
  List<String> get routeName;

  ///
  ///
  ///
  T get modelInstance;

  ///
  ///
  ///
  Future<ConsumerPermission> checkPermission(
    BuildContext context, {
    List<String> paths,
    bool returnLog = false,
  });

  ///
  ///
  ///
  Future<List<T>> list(
    BuildContext context, {
    Map<String, String> qsParam,
    bool returnLog = false,
  });

  ///
  ///
  ///
  Future<T> delete(
    BuildContext context,
    T model, {
    bool returnLog = false,
  });

  ///
  ///
  ///
  Future<T> getById(
    BuildContext context,
    T model, {
    bool returnLog = false,
  });

  ///
  ///
  ///
  Future<bool> saveOrUpdate(
    BuildContext context,
    T model, {
    bool returnLog = false,
  });
}

///
///
///
@immutable
class ConsumerPermission {
  final bool insert;
  final bool update;
  final bool delete;
  final String iconName;
  final String name;

  ///
  ///
  ///
  const ConsumerPermission({
    this.insert = false,
    this.update = false,
    this.delete = false,
    this.iconName = 'solidCircle',
    this.name,
  });
}
