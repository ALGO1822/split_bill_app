import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill_app/cubit/split_bill_state.dart';
import 'package:split_bill_app/models/currency_model.dart';

class SplitBillCubit extends Cubit<SplitBillState> {
  SplitBillCubit() : super(const SplitBillState());

  void updateInput(String key) {
    String currentInput = state.inputAmount;

    if (key == '<') {
      if (currentInput.isNotEmpty) {
        currentInput = currentInput.substring(0, currentInput.length - 1);
      }
    } else if (key == '.') {
      // Safety rules for decimal placement
      if (!state.activeCurrency.hasDecimals) return; // Ignore if NGN
      if (currentInput.contains('.')) return; // Prevent multiple dots
      if (currentInput.isEmpty) currentInput = '0'; // If typing "." first, turn it into "0."
      currentInput += key;
    } else {
      if (currentInput.length >= 10) return;
      
      // Safety check: Prevent entering more than 2 digits after the decimal point
      if (currentInput.contains('.')) {
        final decimalPart = currentInput.split('.')[1];
        if (decimalPart.length >= 2) return; 
      }
      
      // 🔥 UX FIX: If the input is exactly "0" and they type a number, replace the zero
      if (currentInput == '0') {
        currentInput = key;
      } else {
        currentInput += key;
      }
    }
    emit(state.copyWith(inputAmount: currentInput));
  }

  void resetInput() {
    if (state.inputAmount.isEmpty) return;
    emit(state.copyWith(inputAmount: ''));
  }

  void incrementPeople() {
    emit(state.copyWith(peopleCount: state.peopleCount + 1));
  }

  void decrementPeople() {
    if (state.peopleCount > 2) {
      emit(state.copyWith(peopleCount: state.peopleCount - 1));
    }
  }

  void resetPeople() {
    if (state.peopleCount > 1) {
      emit(state.copyWith(peopleCount: 2));
    }
  }

  void toggleTax() {
    emit(state.copyWith(isTaxApplied: !state.isTaxApplied));
  }

  void updateCurrency(CurrencyModel currency) {
    emit(state.copyWith(
      activeCurrency: currency,
      inputAmount: '', // 🔥 Wipes the slate clean to prevent cross-currency calculation bugs
    ));
  }

  void setTaxPercentage(double percentage) {
    emit(state.copyWith(taxPercentage: percentage));
  }

  void toggleRounding() {
    emit(state.copyWith(isRoundingEnabled: !state.isRoundingEnabled));
  }

  void toggleHaptic() {
    emit(state.copyWith(isHapticEnabled: !state.isHapticEnabled));
  }
}