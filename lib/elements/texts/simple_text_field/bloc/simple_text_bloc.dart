import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:omdk/elements/texts/simple_text_field/enum/simple_text_status.dart';

part 'simple_text_event.dart';

part 'simple_text_state.dart';

/// [Bloc] dedicate to [SimpleTextField]
class SimpleTextBloc extends Bloc<SimpleTextEvent, SimpleTextState> {
  /// Create [SimpleTextBloc] instance
  SimpleTextBloc({
    bool isEmptyAllowed = false,
    bool isNullable = false,
    bool isActionEnabled = true,
    bool isInputTextEnabled = true,
  }) : super(
          SimpleTextState(
            isEmptyAllowed: isEmptyAllowed,
            isNullable: isNullable,
            isActionEnabled: isActionEnabled,
            isInputTextEnabled: isInputTextEnabled,
          ),
        ) {
    on<TextChanged>(_onTextChanges);
    on<ValidateData>(_onValidateData);
    on<EnableInputText>(_onEnableInputText);
    on<ResetText>(_onResetText);
  }

  Future<void> _onTextChanges(
    TextChanged event,
    Emitter<SimpleTextState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SimpleTextStatus.initial,
        text: event.text,
        errorText: '',
        cursorPosition: event.cursorPosition,
      ),
    );
  }

  Future<void> _onEnableInputText(
    EnableInputText event,
    Emitter<SimpleTextState> emit,
  ) async {
    emit(state.copyWith(isInputTextEnabled: true));
  }

  Future<void> _onResetText(
    ResetText event,
    Emitter<SimpleTextState> emit,
  ) async {
    emit(
      state.copyWith(
        text: '',
        cursorPosition: 0,
      ),
    );
  }

  Future<void> _onValidateData(
    ValidateData event,
    Emitter<SimpleTextState> emit,
  ) async {
    emit(state.copyWith(status: SimpleTextStatus.validating));
    if (!state.isNullable && state.text == null) {
      return emit(
        state.copyWith(
          status: SimpleTextStatus.failure,
          errorText: '* Mandatory field',
        ),
      );
    }
    if (!state.isEmptyAllowed && state.text != null && state.text!.isEmpty) {
      return emit(
        state.copyWith(
          status: SimpleTextStatus.failure,
          errorText: '* This field cannot be empty',
        ),
      );
    }
    return emit(state.copyWith(status: SimpleTextStatus.success));
  }
}
