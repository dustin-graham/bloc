import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

/// Creates a new [bloc]-specific test case with the given [description].
/// [blocTest] will handle asserting that the [bloc] emits the [expect]ed
/// states (in order) after [act] is executed.
/// [blocTest] also handles ensuring that no additional states are emitted
/// by closing the [bloc] stream before evaluating the [expect]ation.
///
/// [build] should be used for all [bloc] initialization and preparation
/// and must return the [bloc] under test.
///
/// [act] is an optional callback which will be invoked with the [bloc] under test
/// and should be used to `add` events to the [bloc].
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the [bloc] under test such as `debounceTime`.
///
/// [expect] is an `Iterable` of matchers which the [bloc]
/// under test is expected to emit after [act] is executed.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0, 1] when CounterEvent.increment is added',
///   build: () => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   expect: [0, 1],
/// );
/// ```
///
/// [blocTest] can also be used to test the initial state of the [bloc]
/// by omitting [act].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0] when nothing is added',
///   build: () => CounterBloc(),
///   expect: [0],
/// );
/// ```
///
/// [blocTest] can also be used when you need to add multiple events in sequence
/// asynchronously by adding delays in the [act] function.
///
/// ```dart
/// blocTest(
///  'emits [0, 1, 2] when CounterEvent.increment is called multiple times with async act',
///  build: () => CounterBloc(),
///  act: (bloc) async {
///    bloc.add(CounterEvent.increment);
///    await Future.delayed(Duration(milliseconds: 10));
///    bloc.add(CounterEvent.increment);
///  },
///  expect: [0, 1, 2],
///);
/// ```
///
/// [blocTest] can also be used to wait for async operations like `debounceTime`
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0, 1] when CounterEvent.increment is added',
///   build: () => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   wait: const Duration(milliseconds: 300),
///   expect: [0, 1],
/// );
/// ```
///
/// **Note:** when using [blocTest] with state classes which don't override
/// `==` and `hashCode` you can provide an `Iterable` of matchers instead of
/// explicit state instances.
///
/// ```dart
/// blocTest(
///  'emits [StateA, StateB] when MyEvent is added',
///  build: () => MyBloc(),
///  act: (bloc) => bloc.add(MyEvent()),
///  expect: [isA<StateA>(), isA<StateB>()],
/// );
/// ```
@isTest
void blocTest<B extends Bloc<Event, State>, Event, State>(
  String description, {
  @required B Function() build,
  @required Iterable expect,
  Future<void> Function(B bloc) act,
  Duration wait,
}) {
  test(description, () async {
    final bloc = build();
    await emitsExactly(bloc, expect, duration: wait, act: act);
  });
}
