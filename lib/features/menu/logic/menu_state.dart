abstract class MenuState {}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<dynamic> menus;
  MenuLoaded(this.menus);
}

class MenuActionSuccess extends MenuState {
  final String message;
  MenuActionSuccess(this.message);
}

class MenuError extends MenuState {
  final String message;
  MenuError(this.message);
}