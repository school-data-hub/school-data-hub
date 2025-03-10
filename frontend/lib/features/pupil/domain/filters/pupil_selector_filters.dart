import 'package:schuldaten_hub/common/domain/filters/filters.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

class SchoolGradeFilter extends SelectorFilter<PupilProxy, SchoolGrade> {
  SchoolGradeFilter(SchoolGrade schoolGrade)
      : super(name: schoolGrade.value, selector: (proxy) => proxy.schoolGrade);

  @override
  bool matches(PupilProxy item) {
    return selector(item).value == name;
  }
}

class GroupFilter extends SelectorFilter<PupilProxy, String> {
  GroupFilter(String group)
      : super(name: group, selector: (proxy) => proxy.groupId);

  @override
  bool matches(PupilProxy item) {
    //debugger();
    return selector(item) == name;
  }
}

class GenderFilter extends SelectorFilter<PupilProxy, Gender> {
  GenderFilter(Gender gender)
      : super(
            name: gender.value == 'm' ? '♂️' : '♀️',
            selector: (proxy) => Gender.stringToValue[proxy.gender]!);

  @override
  bool matches(PupilProxy item) {
    return selector(item).value == (name == '♂️' ? 'm' : 'w');
  }
}
