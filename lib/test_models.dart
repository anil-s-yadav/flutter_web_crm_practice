import 'models/client_model.dart';
import 'models/contract_model.dart';

void main() {
  try {
    ClientModel.fromJson({});
    print("ClientModel.fromJson({}) passed!");
  } catch (e, stack) {
    print("ClientModel Error: $e\n$stack");
  }

  try {
    ContractModel.fromJson({});
    print("ContractModel.fromJson({}) passed!");
  } catch (e, stack) {
    print("ContractModel Error: $e\n$stack");
  }
}
