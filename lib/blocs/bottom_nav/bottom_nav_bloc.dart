import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bottom_nav_event.dart';
part 'bottom_nav_state.dart';

class BottomNavBloc extends Bloc<BottomNavEvent, BottomNavState> {
  BottomNavBloc() : super(BottomNavNext(2)) {

    on<NavItemSelected>((event, emit) {
      emit(BottomNavNext(event.index));
    });

  }
}
