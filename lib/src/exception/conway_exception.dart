/**
 * Custom Exception for the Conway library
 */
class ConwayException implements Exception {

  String message;
  ConwayException(this.message);

  @override
  String toString() => message;
}
